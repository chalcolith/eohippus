use "logger"
use "net"

class TcpChannel is Channel
  let _log: Logger[String]
  let _listener: TCPListener
  var _conn: (TCPConnection | None) = None

  new create(
    log: Logger[String],
    auth: TCPListenAuth,
    host: String,
    service: String,
    rpc_handler: Handler)
  =>
    _log = log
    _listener = TCPListener(
      auth,
      recover TcpChannelListenNotify(log, rpc_handler) end,
      host,
      service)

  fun valid(): Bool =>
    _conn isnt None

  fun ref write(data: (String val | Array[U8] val)) =>
    _log(Fine) and _log.log(
      "TcpChannel: writing " + data.size().string() + "bytes")

    match _conn
    | let conn: TCPConnection =>
      conn.write(data)
    end

  fun ref flush() =>
    _log(Fine) and _log.log("TcpChannel: flush")
    None

  fun ref close() =>
    match _conn
    | let conn: TCPConnection =>
      _log(Fine) and _log.log("TcpChannel: close")
      conn.dispose()
      _conn = None
    end
    _listener.dispose()

class TcpChannelListenNotify is TCPListenNotify
  let _log: Logger[String]
  let _rpc_handler: Handler
  var _num_connections: USize = 0

  new create(log: Logger[String], rpc_handler: Handler) =>
    _log = log
    _rpc_handler = rpc_handler

  fun ref listening(listen: TCPListener ref) =>
    _log(Fine) and _log.log("ListenNotify: listening")
    _rpc_handler.listening()

  fun ref not_listening(listen: TCPListener ref) =>
    _log(Fine) and _log.log("ListenNotify: not_listening")
    _rpc_handler.closed()

  fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ =>
    _log(Fine) and _log.log("ListenNotify: connected")
    if _num_connections == 0 then
      _num_connections = _num_connections + 1
      _rpc_handler.connected()
      recover TcpChannelConnectionNotify(_log, _rpc_handler) end
    else
      recover TcpChannelConnectionReject(_log) end
    end

  fun ref closed(listen: TCPListener ref) =>
    _log(Fine) and _log.log("ListenNotify: closed")
    _num_connections = _num_connections - 1
    _rpc_handler.closed()

class TcpChannelConnectionReject is TCPConnectionNotify
  let _log: Logger[String]

  new create(log: Logger[String]) =>
    _log = log

  fun ref connected(conn: TCPConnection ref) =>
    _log(Fine) and _log.log("ConnectionReject: rejecting")
    conn.dispose()

  fun ref connect_failed(conn: TCPConnection ref) =>
    _log(Fine) and _log.log("ConnectionReject: connection failed")
    conn.dispose()

class TcpChannelConnectionNotify is TCPConnectionNotify
  let _log: Logger[String]
  let _rpc_handler: Handler

  new create(log: Logger[String], rpc_handler: Handler) =>
    _log = log
    _rpc_handler = rpc_handler

  fun ref connected(conn: TCPConnection ref) =>
    _log(Fine) and _log.log("ConnectionNotify: connected")
    _rpc_handler.connected()

  fun ref connect_failed(conn: TCPConnection ref) =>
    _log(Warn) and _log.log("ConnectionNotify: connect_failed")
    _rpc_handler.connect_failed()

  fun ref auth_failed(conn: TCPConnection ref) =>
    _log(Warn) and _log.log("ConnectionNotify: auth_failed")
    _rpc_handler.connect_failed()

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    _log(Fine) and _log.log(
      "ConnectionNotify: received " + data.size().string() + " bytes")
    _rpc_handler.data_received(consume data)
    true

  fun ref closed(conn: TCPConnection ref) =>
    _log(Fine) and _log.log("ConnectionNotify: closed")
    _rpc_handler.closed()
