interface ServerNotify
  fun ref listening(server: Server) => None
  fun ref connected(server: Server) => None
  fun ref errored(server: Server) => None
  fun ref initializing(server: Server) => None
  fun ref initialized(server: Server) => None
  fun ref received_request(
    server: Server, id: (I128 | String | None), method: String)
  =>
    None
  fun ref received_notification(server: Server, method: String) => None
  fun ref sent_error(
    server: Server, id: (I128 | String | None), code: I128, message: String)
  =>
    None
  fun ref disconnected(server: Server) => None
  fun ref shutting_down(server: Server) => None
  fun ref exiting(code: I32) => None

class val _DummyNotify is ServerNotify
