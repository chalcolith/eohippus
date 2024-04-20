use "logger"
use "net"

use json = "../../json"
use "../.."
use ".."

primitive JsonRpc
  fun version(): String => "2.0"
  fun mime_type(): String => "application/vscode-jsonrpc"
  fun charset(): String => "utf-8"

primitive _NotConnected
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
  | _ExpectHeaderName
  | _InHeaderName
  | _ExpectHeaderValue
  | _InHeaderValue
  | _InEndOfLine
  | _InEndOfHeaders
  | _ExpectJsonObject
  | _InJsonObject
  | _Errored )

actor Handler
  let _log: Logger[String]
  let _server: Server tag
  let _channel: Channel
  let _json_parser: json.Parser

  var _state: _HandlerState
  var _current_header_name: String ref
  var _current_header_value: String ref
  var _current_content_length: U64
  var _current_content_type: String

  new from_streams(
    log: Logger[String],
    server: Server tag,
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

  // new from_tcp(
  //   log: Logger[String],
  //   server: Server,
  //   auth: TcpListenAuth,
  //   host: String,
  //   service: String)
  // =>
  //   _server = server
  //   _channel = TcpChannel(auth, host, service)

  be close() =>
    _log(Fine) and _log.log("close")
    _channel.close()

  be connect_succeeded() =>
    _log(Fine) and _log.log("connect_succeeded")
    _state = _ExpectHeaderName

  be connect_failed() =>
    _log(Fine) and _log.log("connect_failed")
    _error_out("connection failed")

  be channel_closed() =>
    _log(Fine) and _log.log("channel_closed")
    _state = _NotConnected
    _server.rpc_closed()

  be data_received(data: Array[U8] iso) =>
    _log(Fine) and _log.log("data received: " + data.size().string() + " bytes")
    if _state is _NotConnected then
      _error_out("spurious data received when not connected")
      return
    end

    if _state is _Errored then
      _error_out("spurious data received when in an error state")
      return
    end

    for ch in (consume data).values() do
      match _state
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
    | let obj: json.Object box =>
      _handle_rpc_message(obj)
    | let seq: json.Sequence box =>
      for item in seq.values() do
        match item
        | let obj: json.Object box =>
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
      return
    | None =>
      _state = _InJsonObject
    else
      _error_out("only JSON objects or sequences allowed")
    end

  fun ref _handle_rpc_message(obj: json.Object box) =>
    _log(Fine) and _log.log("message: " + obj.get_string(false))

    let id: (I128 | String val | json.Null) =
      match try obj("id")? end
      | let int: I128 =>
        int
      | let str: String box =>
        str.clone()
      else
        json.Null
      end

    try
      let jsonrpc = obj("jsonrpc")? as String box
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

    let params =
      try
        match obj("params")?
        | let obj': json.Object box =>
          obj'
        | let seq: json.Sequence box =>
          seq
        else
          respond_error(
            id,
            ErrorCode.invalid_request(),
            "'params' must be an object or sequence")
          return
        end
      else
        json.Null
      end

    try
      let method = obj("method")? as String box
      match method
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

  be respond(msg: ResponseMessage) =>
    let props =
      [ as (String, json.Item):
        ("jsonrpc", msg.jsonrpc())
        ("id", msg.id()) ]
    match msg.result()
    | let item: json.Item =>
      props.push(("result", item))
    end
    match msg.err()
    | let err: ResponseError =>
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
    msg_id: (I128 | String | json.Null),
    code: I128,
    message: String,
    data: (json.Item val | None) = None)
  =>
    _log(Error) and _log.log("response: error " + code.string() + ":" +
      msg_id.string() + ": " + message)
    respond(
      object val is ResponseMessage
        fun val id(): (I128 | String val | json.Null) => msg_id
        fun val err(): (ResponseError | None) =>
          let code' = code
          let message' = message
          let data' = data
          object val is ResponseError
            fun val code(): I128 => code'
            fun val message(): String => message'
            fun val data(): (json.Item | None) => data'
          end
      end)

  fun _write_message(obj: json.Object) =>
    let body = recover val obj.get_string(false) end
    _log(Fine) and _log.log("response: " + body)

    _channel.write("Content-Length:" + body.size().string() + "\r\n")
    _channel.write(
      "Content-Type:" + JsonRpc.mime_type() + ";" + JsonRpc.charset() + "\r\n")
    _channel.write("\r\n")
    _channel.write(body)
    _channel.write("\r\n")
    _channel.flush()

  fun ref _error_out(message: String) =>
    _log(Error) and _log.log("error: " + message)
    _state = _Errored
    _server.rpc_error()
