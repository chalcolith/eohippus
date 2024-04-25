use "logger"

use json = "../json"

use rpc = "rpc"
use rpc_data = "rpc/data_types"
use req = "requests"
use ".."

interface tag Server
  be set_rpc_handler(rpc_handler: rpc.Handler)
  be rpc_listening()
  be rpc_connected()
  be rpc_error()
  be rpc_closed()
  be dispose()
  be exit()

  be notify_listening()
  be notify_connected()
  be notify_errored()
  be notify_initializing()
  be notify_initialized()
  be notify_received_request(id: (I128 | String | None), method: String)
  be notify_received_notification(method: String)
  be notify_sent_error(id: (I128 | String | None), code: I128, message: String)
  be notify_disconnected()
  be notify_shutting_down()
  be notify_exiting(code: I32)

  be request_initialize(
    message: rpc_data.RequestMessage,
    params: rpc_data.InitializeParams)
  be notification_initialized()
  be request_shutdown(message: rpc_data.RequestMessage)
  be notification_exit()

primitive ServerNotConnected
primitive ServerNotInitialized
primitive ServerInitializing
primitive ServerInitialized
primitive ServerShuttingDown
primitive ServerExiting

type ServerState is
  ( ServerNotConnected
  | ServerNotInitialized
  | ServerInitializing
  | ServerInitialized
  | ServerShuttingDown
  | ServerExiting )

actor EohippusServer is Server
  let _env: Env
  let _log: Logger[String]

  var _notify: ServerNotify iso
  var _rpc_handler: rpc.Handler

  var _state: ServerState = ServerNotConnected
  var _trace_value: rpc_data.TraceValue = rpc_data.TraceMessages
  var _exit_code: I32 = 0

  let _handle_initialize: req.Initialize
  let _handle_shutdown: req.Shutdown

  new create(
    env: Env,
    log: Logger[String],
    notify: (ServerNotify iso | None) = None,
    rpc_handler: (rpc.Handler | None) = None)
  =>
    _env = env
    _log = log
    _notify =
      match notify
      | let sn: ServerNotify iso =>
        consume sn
      else
        _DummyNotify
      end
    _rpc_handler =
      match rpc_handler
      | let rh: rpc.Handler =>
        rh
      else
        rpc.DummyHandler(_log)
      end

    _handle_initialize = req.Initialize(_log, this)
    _handle_shutdown = req.Shutdown(_log, this)

  be set_notify(notify: ServerNotify iso) =>
    _log(Fine) and _log.log("server notify set")
    _notify = consume notify

  be notify_listening() =>
    let self: Server tag = this
    _notify.listening(self)

  be notify_connected() =>
    let self: Server tag = this
    _notify.connected(self)

  be notify_errored() =>
    let self: Server tag = this
    _notify.errored(self)

  be notify_initializing() =>
    let self: Server tag = this
    _notify.initializing(self)

  be notify_initialized() =>
    let self: Server tag = this
    _notify.initialized(self)

  be notify_received_request(id: (I128 | String | None), method: String) =>
    let self: Server tag = this
    _notify.received_request(self, id, method)

  be notify_received_notification(method: String) =>
    let self: Server tag = this
    _notify.received_notification(self, method)

  be notify_sent_error(
    id: (I128 | String | None), code: I128, message: String)
  =>
    let self: Server tag = this
    _notify.sent_error(self, id, code, message)

  be notify_disconnected() =>
    let self: Server tag = this
    _notify.disconnected(self)

  be notify_shutting_down() =>
    let self: Server tag = this
    _notify.shutting_down(self)

  be notify_exiting(code: I32) =>
    _notify.exiting(code)

  be set_rpc_handler(rpc_handler: rpc.Handler) =>
    _log(Info) and _log.log("server rpc handler set")
    _rpc_handler = rpc_handler

  be rpc_listening() =>
    _log(Info) and _log.log("server rpc handler listening")
    notify_listening()

  be rpc_connected() =>
    _log(Info) and _log.log("server rpc handler connected")
    _state = ServerNotInitialized
    notify_connected()

  be rpc_error() =>
    _log(Info) and _log.log("rpc handler error")
    _exit_code = 1
    notify_errored()
    exit()

  be rpc_closed() =>
    _log(Info) and _log.log("rpc handler closed")
    notify_disconnected()
    exit()

  be dispose() =>
    _log(Info) and _log.log("server disposed; closing rpc handler")
    _rpc_handler.close()

  be exit() =>
    if _state isnt ServerExiting then
      _log(Info) and _log.log("server exiting with code " + _exit_code.string())
      // make sure things are cleaned up
      _state = ServerExiting
      _env.exitcode(_exit_code)
      notify_exiting(_exit_code)
    end

  be request_initialize(
    message: rpc_data.RequestMessage,
    params: rpc_data.InitializeParams)
  =>
    _handle_request(_handle_initialize(_state, _rpc_handler, message, params))

  be request_shutdown(message: rpc_data.RequestMessage) =>
    _handle_request(_handle_shutdown(_state, _rpc_handler, message))

  fun ref _handle_request(status: ((ServerState | None), (I32 | None))) =>
    match status._1
    | let state: ServerState =>
      _state = state
    end
    match status._2
    | let exit_code: I32 =>
      _exit_code = exit_code
    end

  be notification_initialized() =>
    _log(Fine) and _log.log("notification: initialized")
    notify_received_notification("initialized")
    if _state is ServerInitializing then
      _state = ServerInitialized
      notify_initialized()
    else
      _log(Error) and _log.log("initialized notification when not initializing")
    end

  be notification_exit() =>
    _log(Fine) and _log.log("notification: exit")
    notify_received_notification("exit")
    var close_handler = false
    match _state
    | ServerNotInitialized =>
      _log(Warn) and _log.log("  ungraceful exit requested before initialize")
      _state = ServerExiting
      _exit_code = 1
      close_handler = true
    | ServerInitializing =>
      _log(Warn) and _log.log("  ungraceful exit requested while initializing")
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
      notify_exiting(_exit_code)
      _rpc_handler.close()
    end
