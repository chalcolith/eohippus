use "logger"

use rpc = "../rpc"
use rpc_data = "../rpc/data"
use ".."

class Shutdown
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
    message: rpc_data.RequestMessage): ((ServerState | None), (I32 | None))
  =>
    _log(Fine) and _log.log(
      "request " + message.id().string() + ": " + message.method())
    _server.notify_received_request(message.id(), message.method())

    if server_state is ServerInitialized then
      // clean things up
      rpc_handler.respond(
        object val is rpc_data.ResponseMessage
          fun val id(): (I128 | String | None) => message.id()
        end)
      _server.notify_shutting_down()
      (ServerShuttingDown, None)
    elseif
      (server_state is ServerShuttingDown) or (server_state is ServerExiting)
    then
      _log(Error) and _log.log("shutdown request duplicated")
      (None, None)
    else
      _log(Error) and _log.log("shutdown request before initialized")
      let message_id = message.id()
      let error_code = rpc.ErrorCode.server_not_initialized()
      let error_message = "server not initialized; shutting down anyway"
      _server.notify_sent_error(message_id, error_code, error_message)
      rpc_handler.respond_error(message_id, error_code, error_message)
      _server.exit()
      (ServerShuttingDown, 1)
    end
