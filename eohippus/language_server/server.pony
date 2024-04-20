use "logger"

use json = "../json"

use rpc = "rpc"

interface Server
  be set_rpc_handler(rpc_handler: rpc.Handler)
  be rpc_error()
  be rpc_closed()

  be request_shutdown(msg: rpc.RequestMessage)
  be notification_exit()

primitive ServerNotConnected
primitive ServerNotInitialized
primitive ServerInitialized
primitive ServerShuttingDown
primitive ServerExiting

type ServerState is
  ( ServerNotConnected
  | ServerNotInitialized
  | ServerInitialized
  | ServerShuttingDown
  | ServerExiting )

interface val ServerNotify
  fun connected() => None
  fun errored() => None
  fun disconnected() => None
  fun shutting_down() => None
  fun exiting(code: I32) => None

actor EohippusServer is Server
  let _env: Env
  let _log: Logger[String]

  var _notify: (ServerNotify | None)
  var _state: ServerState = ServerNotConnected
  var _rpc_handler: (rpc.Handler | None) = None
  var _exit_code: I32 = 0

  new create(
    env: Env,
    log: Logger[String],
    notify: (ServerNotify | None) = None)
  =>
    _env = env
    _log = log
    _notify = notify

  be set_notify(notify: ServerNotify) =>
    _log(Fine) and _log.log("server notify set")
    _notify = notify

  be set_rpc_handler(rpc_handler: rpc.Handler) =>
    _log(Info) and _log.log("server rpc handler set")
    _state = ServerNotInitialized
    _rpc_handler = rpc_handler
    match _notify
    | let notify: ServerNotify =>
      notify.connected()
    end

  be rpc_error() =>
    _log(Info) and _log.log("rpc handler error")
    _exit_code = 1
    match _notify
    | let notify: ServerNotify =>
      notify.errored()
    end
    exit()

  be rpc_closed() =>
    _log(Info) and _log.log("rpc handler closed")
    match _notify
    | let notify: ServerNotify =>
      notify.disconnected()
    end
    exit()

  be exit() =>
    _log(Info) and _log.log("server exiting with code " + _exit_code.string())
    // make sure things are cleaned up
    _state = ServerExiting
    _env.exitcode(_exit_code)
    match _notify
    | let notify: ServerNotify =>
      notify.exiting(_exit_code)
    end

  be request_shutdown(msg: rpc.RequestMessage) =>
    _log(Fine) and _log.log("request: " + msg.method())

    match _state
    | ServerNotConnected =>
      _log(Error) and _log.log("shutdown request before connection?")
      _exit_code = 1
      this.exit()
    | ServerNotInitialized =>
      _log(Error) and _log.log("shutdown request before initialized")
      _exit_code = 1
      match _rpc_handler
      | let rpc_handler: rpc.Handler =>
        rpc_handler.respond_error(
          msg.id(),
          rpc.ErrorCode.server_not_initialized(),
          "server not initialized; shutting down")
      end
      this.exit()
    | ServerInitialized =>
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
      match _notify
      | let notify: ServerNotify =>
        notify.shutting_down()
      end
    end

  be notification_exit() =>
    _log(Fine) and _log.log("notification: exit")
    var close_handler = false
    match _state
    | ServerNotInitialized =>
      _log(Warn) and _log.log("  ungraceful exit requested before initialize")
      _state = ServerExiting
      _exit_code = 1
      close_handler = true
    | ServerInitialized =>
      _log(Warn) and _log.log("  ungraceful exit requested before shutdown")
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
