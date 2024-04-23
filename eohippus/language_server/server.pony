use "logger"

use json = "../json"

use rpc = "rpc"
use rpc_data = "rpc/data_types"
use req = "requests"
use ".."

interface tag Server
  be set_rpc_handler(rpc_handler: rpc.Handler)
  be rpc_error()
  be rpc_closed()

  be exit()

  be request_initialize(
    message: rpc_data.RequestMessage,
    params: rpc_data.InitializeParams)
  be notification_initialized()
  be request_shutdown(message: rpc_data.RequestMessage)
  be notification_exit()

interface val ServerNotify
  fun connected() => None
  fun errored() => None
  fun initializing() => None
  fun initialized() => None
  fun received_request(id: (I128 | String | None), method: String) => None
  fun received_notification(method: String) => None
  fun sent_error(id: (I128 | String | None), code: I128, message: String) =>
    None
  fun disconnected() => None
  fun shutting_down() => None
  fun exiting(code: I32) => None

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

  var _notify: ServerNotify
  var _rpc_handler: rpc.Handler

  var _state: ServerState = ServerNotConnected
  var _trace_value: rpc_data.TraceValue = rpc_data.TraceMessages
  var _exit_code: I32 = 0

  let _handle_initialize: req.Initialize
  let _handle_shutdown: req.Shutdown

  new create(
    env: Env,
    log: Logger[String],
    notify: (ServerNotify | None) = None,
    rpc_handler: (rpc.Handler | None) = None)
  =>
    _env = env
    _log = log
    _notify =
      match notify
      | let sn: ServerNotify =>
        sn
      else
        _DummyNotify
      end
    _rpc_handler =
      match rpc_handler
      | let rh: rpc.Handler =>
        rh
      else
        _DummyHandler(_log)
      end

    _handle_initialize = req.Initialize(_log, this, _notify)
    _handle_shutdown = req.Shutdown(_log, this, _notify)

  be set_notify(notify: ServerNotify) =>
    _log(Fine) and _log.log("server notify set")
    _notify = notify

  be set_rpc_handler(rpc_handler: rpc.Handler) =>
    _log(Info) and _log.log("server rpc handler set")
    _state = ServerNotInitialized
    _rpc_handler = rpc_handler
    _notify.connected()

  be rpc_error() =>
    _log(Info) and _log.log("rpc handler error")
    _exit_code = 1
    _notify.errored()
    exit()

  be rpc_closed() =>
    _log(Info) and _log.log("rpc handler closed")
    _notify.disconnected()
    exit()

  be exit() =>
    _log(Info) and _log.log("server exiting with code " + _exit_code.string())
    // make sure things are cleaned up
    _state = ServerExiting
    _env.exitcode(_exit_code)
    _notify.exiting(_exit_code)

  be request_initialize(
    message: rpc_data.RequestMessage,
    params: rpc_data.InitializeParams)
  =>
    _notify.received_request(message.id(), message.method())
    _handle_request(_handle_initialize(_state, _rpc_handler, message, params))

  be request_shutdown(message: rpc_data.RequestMessage) =>
    _notify.received_request(message.id(), message.method())
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
    _notify.received_notification("initialized")
    if _state is ServerInitializing then
      _state = ServerInitialized
      _notify.initialized()
    else
      _log(Error) and _log.log("initialized notification when not initializing")
    end

  be notification_exit() =>
    _log(Fine) and _log.log("notification: exit")
    _notify.received_notification("exit")
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
      _notify.exiting(_exit_code)
      _rpc_handler.close()
    end

class val _DummyNotify is ServerNotify

actor _DummyHandler is rpc.Handler
  let _log: Logger[String]

  new create(log: Logger[String]) =>
    _log = log

  be close() =>
    _log(Warn) and _log.log("handler.close(): no handler set")

  be connect_succeeded() =>
    _log(Warn) and _log.log("handler.connect_succeeded(): no handler set")

  be connect_failed() =>
    _log(Warn) and _log.log("handler.connect_failed(): no handler set")

  be channel_closed() =>
    _log(Warn) and _log.log("handler.channel_closed(): no handler set")

  be data_received(data: Array[U8] iso) =>
    _log(Warn) and _log.log("handler.data_received(): no handler set")

  be respond(msg: rpc_data.ResponseMessage) =>
    _log(Warn) and _log.log("handler.respond(): no handler set")

  be respond_error(
    msg_id: (I128 | String | None),
    code: I128,
    message: String,
    data: (json.Item val | None) = None)
  =>
    _log(Warn) and _log.log("handler.response_error(): no handler set")
