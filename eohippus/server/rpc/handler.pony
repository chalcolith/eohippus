use "logger"
use "net"

use json = "../../json"

use rpc_data = "data"
use c_caps = "data/client_capabilities"
use "../.."
use ".."

primitive JsonRpc
  fun version(): String => "2.0"
  fun mime_type(): String => "application/vscode-jsonrpc"
  fun charset(): String => "utf-8"

primitive _NotConnected
primitive _BetweenMessages
primitive _ExpectHeaderName
primitive _InHeaderName
primitive _ExpectHeaderValue
primitive _InHeaderValue
primitive _InEndOfLine
primitive _InEndOfHeaders
primitive _ExpectJsonObject
primitive _InJsonObject
primitive _Errored

type _HandlerState is
  ( _NotConnected
  | _BetweenMessages
  | _ExpectHeaderName
  | _InHeaderName
  | _ExpectHeaderValue
  | _InHeaderValue
  | _InEndOfLine
  | _InEndOfHeaders
  | _ExpectJsonObject
  | _InJsonObject
  | _Errored )

interface tag Handler
  be close()
  be listening()
  be connected()
  be connect_failed()
  be data_received(data: Array[U8] iso)
  be notify(method: String, params: rpc_data.NotificationParams)
  be respond(msg: rpc_data.ResponseMessage)
  be respond_error(
    msg_id: (I128 | String | None),
    code: I128,
    message: String,
    data: (json.Item val | None) = None)
  be closed()

actor EohippusHandler is Handler
  let _log: Logger[String]
  let _server: Server
  let _channel: Channel
  let _json_parser: json.Parser

  var _state: _HandlerState
  var _current_header_name: String ref
  var _current_header_value: String ref
  var _current_content_length: U64
  var _current_content_type: String

  new from_streams(
    log: Logger[String],
    server: Server,
    input: InputStream,
    output: OutStream)
  =>
    _log = log
    _server = server
    _server.set_rpc_handler(this)
    _channel = StreamChannel(log, input, output, this)
    _json_parser = json.Parser

    _state = _NotConnected
    _current_header_name = String
    _current_header_value = String
    _current_content_length = 0
    _current_content_type = String

  new from_tcp(
    log: Logger[String],
    server: Server,
    auth: TCPConnectAuth,
    host: String,
    service: String)
  =>
    _log = log
    _server = server
    _server.set_rpc_handler(this)
    _channel = TcpChannel(log, auth, host, service, this)
    _json_parser = json.Parser

    _state = _NotConnected
    _current_header_name = String
    _current_header_value = String
    _current_content_length = 0
    _current_content_type = String

  be close() =>
    _log(Fine) and _log.log("close")
    _channel.close()

  be listening() =>
    _log(Fine) and _log.log("listening")
    _server.rpc_listening()

  be connected() =>
    _log(Fine) and _log.log("connect_succeeded")
    _state = _ExpectHeaderName
    _server.rpc_connected()

  be connect_failed() =>
    _log(Fine) and _log.log("connect_failed")
    _error_out("connection failed")

  be data_received(buf: Array[U8] iso) =>
    if _state is _NotConnected then
      _error_out("spurious data received when not connected")
      return
    end

    if _state is _Errored then
      _error_out("spurious data received when in an error state")
      return
    end

    _log(Fine) and _log.log("data received: " + buf.size().string() + " bytes")

    for ch in (consume buf).values() do
      match _state
      | _BetweenMessages =>
        if StringUtil.is_ws(ch) then
          None
        else
          _state = _InHeaderName
          _current_header_name.clear()
          _current_header_name.push(ch)
        end
      | _ExpectHeaderName =>
        if ch == '\n' then
          _error_out("\\n encountered; expected header name")
          return
        elseif ch == '\r' then
          _state = _InEndOfHeaders
        elseif StringUtil.is_ws(ch) then
          None
        elseif ch == ':' then
          _error_out("invalid character ':'; expected header name")
          return
        else
          _state = _InHeaderName
          _current_header_name.clear()
          _current_header_name.push(ch)
        end
      | _InHeaderName =>
        if ch == ':' then
          _state = _ExpectHeaderValue
        else
          _current_header_name.push(ch)
        end
      | _ExpectHeaderValue =>
        if (ch == '\r') or (ch == '\n') then
          _error_out("EOL encountered; expected header value")
          return
        elseif StringUtil.is_ws(ch) then
          None
        else
          _state = _InHeaderValue
          _current_header_value.clear()
          _current_header_value.push(ch)
        end
      | _InHeaderValue =>
        if ch == '\n' then
          _error_out("\\n encountered; expected \\r\\n")
          return
        elseif ch == '\r' then
          _log(Fine) and _log.log(
            "header: " + _current_header_name + ": " + _current_header_value)
          if _current_header_name == "Content-Length" then
            _current_content_length =
              try _current_header_value.u64()? else 0 end
          elseif _current_header_name == "Content-Type" then
            _current_content_type = _current_header_value.clone()
          else
            _error_out("unknown header name '" + _current_header_name + "'")
            return
          end
          _state = _InEndOfLine
        else
          _current_header_value.push(ch)
        end
      | _InEndOfLine =>
        if ch != '\n' then
          _error_out("expected \\n in EOL")
          return
        else
          _state = _ExpectHeaderName
        end
      | _InEndOfHeaders =>
        if ch != '\n' then
          _error_out("expected \\n in EOL")
          return
        else
          _state = _ExpectJsonObject
          _json_parser.reset()
        end
      | _ExpectJsonObject =>
        if StringUtil.is_ws(ch) then
          None
        elseif (ch == '{') or (ch == '[') then
          _process_json_char(ch)
        else
          _error_out("expected JSON object")
          return
        end
      | _InJsonObject =>
        _process_json_char(ch)
      end
    end

  fun ref _process_json_char(ch: U8) =>
    match _json_parser.parse_char(ch)
    | let obj: json.Object val =>
      _handle_rpc_message(obj)
      _state = _BetweenMessages
    | let seq: json.Sequence val =>
      for item in seq.values() do
        match item
        | let obj: json.Object val =>
          _handle_rpc_message(obj)
          if _state is _Errored then break end
        else
          _error_out("only JSON objects allowed in sequence")
          break
        end
      end
    | let err: json.ParseError =>
      _error_out(
        "JSON parse error at " + err.index.string() + ": " + err.message)
    | None =>
      _state = _InJsonObject
    else
      _error_out("only JSON objects or sequences allowed")
    end

  fun ref _handle_rpc_message(obj: json.Object val) =>
    let id: (I128 | String) =
      match try obj("id")? end
      | let int: I128 =>
        int
      | let str: String val =>
        str
      else
        I128(-1)
      end

    try
      let jsonrpc = obj("jsonrpc")? as String val
      if jsonrpc != JsonRpc.version() then
        respond_error(
          id,
          ErrorCode.invalid_request(),
          "invalid jsonrpc version '" + jsonrpc + "'; only '" +
            JsonRpc.version() + "' allowed")
        return
      end
    else
      respond_error(
        id,
        ErrorCode.invalid_request(),
        "an rpc message must contain a 'jsonrpc' property")
      return
    end

    let params: (json.Object val | json.Sequence val | None) =
      try
        match obj("params")?
        | let obj': json.Object val =>
          obj'
        | let seq: json.Sequence val =>
          seq
        else
          respond_error(
            id,
            ErrorCode.invalid_request(),
            "'params' must be an object or sequence")
          return
        end
      end

    try
      let method = obj("method")? as String
      _log(Fine) and _log.log("message: " + method)

      match method
      | "initialize" =>
        _handle_initialize(id, params)
      | "initialized" =>
        _server.notification_initialized()
      | "shutdown" =>
        _handle_shutdown(id)
      | "$/setTrace" =>
        _handle_set_trace(params)
      | "textDocument/didOpen" =>
        _handle_text_document_did_open(params)
      | "textDocument/didChange" =>
        _handle_text_document_did_change(params)
      | "textDocument/didClose" =>
        _handle_text_document_did_close(params)
      | "exit" =>
        _server.notification_exit()
      else
        respond_error(
          id,
          ErrorCode.method_not_found(),
          "unknown method '" + method + "'")
      end
    else
      respond_error(
        id,
        ErrorCode.invalid_request(),
        "an rpc message must contain a 'method' property of type string")
    end

  fun _handle_initialize(
    message_id: (I128 | String),
    params_item: (json.Object val | json.Sequence val | None))
  =>
    match params_item
    | let params_obj: json.Object val =>
      match rpc_data.ParseInitializeParams(params_obj)
      | let params: rpc_data.InitializeParams =>
        _server.request_initialize(
          object val is rpc_data.RequestMessage
            fun val id(): (I128 | String) => message_id
            fun val method(): String => "initialize"
          end,
          params)
      | let err: String =>
        respond_error(message_id, ErrorCode.invalid_params(), err)
      end
    else
      respond_error(
        message_id,
        ErrorCode.invalid_params(),
        "an 'initialize' request must contain 'params' of type Object")
    end

  fun _handle_set_trace(
    params_item: (json.Object val | json.Sequence val | None))
  =>
    match params_item
    | let params_obj: json.Object val =>
      match rpc_data.ParseSetTraceParams(params_obj)
      | let stp: rpc_data.SetTraceParams =>
        _server.notification_set_trace(stp)
      | let err: String =>
        _log(Warn) and _log.log("$/setTrace: " + err)
      end
    else
      _log(Warn) and _log.log("$/setTrace params should be an object")
    end

  fun _handle_text_document_did_open(
    params_item: (json.Object val | json.Sequence val | None))
  =>
    match params_item
    | let params_obj: json.Object val =>
      match rpc_data.ParseDidOpenTextDocumentParams(params_obj)
      | let dotdp: rpc_data.DidOpenTextDocumentParams =>
        _server.notification_did_open_text_document(dotdp)
      | let err: String =>
        _log(Warn) and _log.log("textDocument/didOpen: " + err)
      end
    else
      _log(Warn) and _log.log("textDocument/didOpen params should be an object")
    end

  fun _handle_text_document_did_change(
    params_item: (json.Object val | json.Sequence val | None))
  =>
    match params_item
    | let params_obj: json.Object val =>
      match rpc_data.ParseDidChangeTextDocumentParams(params_obj)
      | let dctdp: rpc_data.DidChangeTextDocumentParams =>
        _server.notification_did_change_text_document(dctdp)
      | let err: String =>
        _log(Warn) and _log.log("textDocument/didChange: " + err)
      end
    else
      _log(Warn) and _log.log(
        "textDocument/didChange params should be an object")
    end

  fun _handle_text_document_did_close(
    params_item: (json.Object val | json.Sequence val | None))
  =>
    match params_item
    | let params_obj: json.Object val =>
      match rpc_data.ParseDidCloseTextDocumentParams(params_obj)
      | let dctdp: rpc_data.DidCloseTextDocumentParams =>
        _server.notification_did_close_text_document(dctdp)
      | let err: String =>
        _log(Warn) and _log.log("textDocument/didClose: " + err)
      end
    else
      _log(Warn) and
        _log.log("textDocument/didClose params should be an object")
    end

  fun _handle_shutdown(message_id: (I128 | String)) =>
    _server.request_shutdown(
      object val is rpc_data.RequestMessage
        fun val id(): (I128 | String) => message_id
        fun val method(): String => "shutdown"
      end)

  be notify(method: String, params: rpc_data.NotificationParams) =>
    _log(Fine) and _log.log("send notification: " + method)
    let props =
      [ as (String, json.Item):
        ("jsonrpc", JsonRpc.version())
        ("method", method)
        ("params", params.get_json()) ]
    _write_message(json.Object(props))

  be respond(msg: rpc_data.ResponseMessage) =>
    _log(Fine) and _log.log("send response: " + msg.id().string())
    let props = [ as (String, json.Item): ("jsonrpc", msg.jsonrpc()) ]
    match msg.id()
    | let id_item: (I128 | String) =>
      props.push(("id", id_item))
    end
    match msg.result()
    | let data: rpc_data.ResultData =>
      props.push(("result", data.get_json()))
    end
    match msg.err()
    | let err: rpc_data.ResponseError =>
      let eprops =
        [ as (String, json.Item):
          ("code", err.code())
          ("message", err.message()) ]
      match err.data()
      | let item: json.Item =>
        eprops.push(("data", item))
      end
      props.push(("error", json.Object(eprops)))
    end
    _write_message(json.Object(props))

  be respond_error(
    msg_id: (I128 | String | None),
    code: I128,
    message: String,
    data: (json.Item val | None) = None)
  =>
    _log(Error) and _log.log(
      "send response: error: " + msg_id.string() + ":" + code.string())
    respond(
      object val is rpc_data.ResponseMessage
        fun val id(): (I128 | String | None) =>
          match msg_id
          | let n: I128 if n != -1 =>
            n
          | let s: String =>
            s
          end
        fun val err(): (rpc_data.ResponseError | None) =>
          let code' = code
          let message' = message
          let data' = data
          object val is rpc_data.ResponseError
            fun val code(): I128 => code'
            fun val message(): String => message'
            fun val data(): (json.Item | None) => data'
          end
      end)

  be closed() =>
    _log(Fine) and _log.log("closed")
    _state = _NotConnected
    _server.rpc_closed()

  fun ref _write_message(obj: json.Object) =>
    let body = recover val obj.get_string(false) end
    let message: String trn = String
    message.append("Content-Length:")
    message.append(body.size().string())
    message.append("\r\n\r\n")
    message.append(body)
    _channel.write(consume message)
    _channel.flush()

  fun ref _error_out(message: String) =>
    _log(Error) and _log.log("error: " + message)
    _state = _Errored
    _server.rpc_error()

actor DummyHandler is Handler
  let _log: Logger[String]

  new create(log: Logger[String]) =>
    _log = log

  be close() =>
    _log(Warn) and _log.log("handler.close(): no handler set")

  be listening() =>
    _log(Warn) and _log.log("handler.listening(): no handler set")

  be connected() =>
    _log(Warn) and _log.log("handler.connect_succeeded(): no handler set")

  be connect_failed() =>
    _log(Warn) and _log.log("handler.connect_failed(): no handler set")

  be data_received(data: Array[U8] iso) =>
    _log(Warn) and _log.log("handler.data_received(): no handler set")

  be notify(method: String, params: rpc_data.NotificationParams) =>
    _log(Warn) and _log.log("handler.notiry(): no handler set")

  be respond(msg: rpc_data.ResponseMessage) =>
    _log(Warn) and _log.log("handler.respond(): no handler set")

  be respond_error(
    msg_id: (I128 | String | None),
    code: I128,
    message: String,
    data: (json.Item val | None) = None)
  =>
    _log(Warn) and _log.log("handler.response_error(): no handler set")

  be closed() =>
    _log(Warn) and _log.log("handler.channel_closed(): no handler set")
