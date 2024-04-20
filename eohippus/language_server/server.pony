use "logger"

use json = "../json"

use rpc = "rpc"

interface Server
  be set_rpc_handler(rpc_handler: rpc.Handler)
  be rpc_error()
  be rpc_closed()

  be request_shutdown(msg: rpc.RequestMessage)
  be notification_exit()

primitive ServerNotInitialized
primitive ServerInitialized
primitive ServerShuttingDown
primitive ServerExiting

type ServerState is
  ( ServerNotInitialized
  | ServerInitialized
  | ServerShuttingDown
  | ServerExiting )

actor EohippusServer is Server
  let _env: Env
  let _log: Logger[String]

  var _state: ServerState = ServerNotInitialized
  var _rpc_handler: (rpc.Handler | None) = None
  var _exit_code: I32 = 0

  new create(env: Env, log: Logger[String]) =>
    _env = env
    _log = log

  be set_rpc_handler(rpc_handler: rpc.Handler) =>
    _rpc_handler = rpc_handler

  be rpc_error() =>
    _exit_code = 1
    exit()

  be rpc_closed() =>
    exit()

  be exit() =>
    // make sure things are cleaned up
    _state = ServerExiting
    _log(Info) and _log.log("server exiting with code " + _exit_code.string())
    _env.exitcode(_exit_code)

  be request_shutdown(msg: rpc.RequestMessage) =>
    // clean things up
    _state = ServerShuttingDown
    match _rpc_handler
    | let rpc_handler: rpc.Handler =>
      let msg_id = msg.id()
      rpc_handler.respond(
        object val is rpc.ResponseMessage
          fun val id(): (I128 | String val | json.Null) => msg_id
          fun val result(): (json.Item | None) => json.Null
        end)
    end

  be notification_exit() =>
    _log(Fine) and _log.log("notification: exit")
    var close_handler = false
    match _state
    | ServerNotInitialized =>
      _log(Warn) and _log.log("ungraceful exit requested without shutdown")
      _state = ServerExiting
      _exit_code = 1
      close_handler = true
    | ServerInitialized =>
      _log(Warn) and _log.log("ungraceful exit requested without shutdown")
      _state = ServerExiting
      _exit_code = 1
      close_handler = true
    | ServerShuttingDown =>
      _state = ServerExiting
      _exit_code = 0
      close_handler = true
    end

    if close_handler then
      match _rpc_handler
      | let rpc_handler: rpc.Handler =>
        rpc_handler.close()
      end
    end
