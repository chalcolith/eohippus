use "logger"

use json = "../../json"
use rpc = "../rpc"
use rpc_data = "../rpc/data"
use c_caps = "../rpc/data/client_capabilities"
use s_caps = "../rpc/data/server_capabilities"
use "../.."
use ".."

class Initialize
  let _log: Logger[String]
  let _server: Server

  new create(
    log: Logger[String],
    server: Server)
  =>
    _log = log
    _server = server

  fun apply(
    server_state: ServerState,
    rpc_handler: rpc.Handler,
    message: rpc_data.RequestMessage,
    params: rpc_data.InitializeParams): ((ServerState | None), (I32 | None))
  =>
    _log(Fine) and _log.log(
      "request " + message.id().string() + ": " + message.method())
    _server.notify_received_request(message.id(), message.method())

    match server_state
    | ServerNotConnected =>
      _log(Error) and _log.log("initialize request before connection?")
      _server.exit()
      return (None, 1)
    | ServerNotInitialized =>
      // get position encoding
      let position_encoding =
        match _get_position_encoding(message.id(), params)
        | let pe: rpc_data.PositionEncodingKind =>
          pe
        else
          rpc_handler.respond_error(
            message.id(),
            rpc.ErrorCode.request_failed(),
            "we only handle utf-8 position encodings",
            recover val
              json.Object([ as (String, json.Item): ("retry", false) ])
            end)
          return (None, None)
        end

      // send response
      let server_info' =
        object val is rpc_data.ServerInfo
          fun val name(): String => "Eohippus Pony Language Server"
          fun val version(): String => Version()
        end
      let text_document_sync_options' =
        object val is s_caps.TextDocumentSyncOptions
          fun val openClose(): (Bool | None) => true
          fun val change(): (s_caps.TextDocumentSyncKind | None) =>
            s_caps.TextDocumentSyncIncremental
        end
      let server_capabilities' =
        object val is s_caps.ServerCapabilities
          fun val positionEncoding(): rpc_data.PositionEncodingKind =>
            position_encoding
          fun val textDocumentSync()
            : (s_caps.TextDocumentSyncOptions | None)
          =>
            text_document_sync_options'
        end
      let result' =
        object val is rpc_data.InitializeResult
          fun val serverInfo(): rpc_data.ServerInfo => server_info'
          fun val capabilities(): s_caps.ServerCapabilities =>
            server_capabilities'
        end
      rpc_handler.respond(
        object val is rpc_data.ResponseMessage
          fun val id(): (I128 | String | None) => message.id()
          fun val result(): rpc_data.ResultData => result'
        end)
      _server.notify_initializing()
      _server.set_client_data(
        params.capabilities(),
        params.workspaceFolders(),
        params.rootUri(),
        params.rootPath())
      (ServerInitializing, None)
    else
      _log(Error) and _log.log("initialize request when already initialized!")
      let message_id = message.id()
      let error_code = rpc.ErrorCode.request_failed()
      let error_message = "already initialized"
      _server.notify_sent_error(message_id, error_code, error_message)
      rpc_handler.respond_error(
        message_id,
        error_code,
        error_message,
        recover val
          json.Object([ as (String, json.Item): ("retry", false) ])
        end)
      (None, None)
    end

  fun _get_position_encoding(
    msg_id: (I128 | String | None),
    params: rpc_data.InitializeParams): (rpc_data.PositionEncodingKind | None)
  =>
    // we only do utf-8
    var found_utf8 = false
    var found_utf16 = false
    match params.capabilities().general()
    | let general: c_caps.GeneralClientCapabilities =>
      match general.positionEncodings()
      | let position_encodings: Array[rpc_data.PositionEncodingKind] val =>
        for pe in position_encodings.values() do
          if pe is rpc_data.PositionEncodingUtf8 then
            found_utf8 = true
          elseif pe is rpc_data.PositionEncodingUtf16 then
            found_utf16 = true
          end
        end
      end
    end
    if found_utf8 then
      rpc_data.PositionEncodingUtf8
    elseif found_utf16 then
      rpc_data.PositionEncodingUtf16
    end
