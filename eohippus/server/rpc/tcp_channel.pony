use "logger"
use "net"

class TcpChannel is Channel
  let _log: Logger[String]
  var _connection: TCPConnection

  new create(
    log: Logger[String],
    auth: TCPConnectAuth,
    host: String,
    service: String,
    rpc_handler: Handler)
  =>
    _log = log
    _connection = TCPConnection(
      auth,
      recover TcpChannelConnectionNotify(log, rpc_handler) end,
      host,
      service)

  fun ref write(data: (String val | Array[U8] val)) =>
    _log(Fine) and _log.log(
      "writing " + data.size().string() + " bytes")
    _connection.write(data)

  fun ref flush() =>
    _log(Fine) and _log.log("flush")
    None

  fun ref close() =>
    _log(Fine) and _log.log("close")
    _connection.dispose()

class TcpChannelConnectionNotify is TCPConnectionNotify
  let _log: Logger[String]
  let _rpc_handler: Handler

  new create(log: Logger[String], rpc_handler: Handler) =>
    _log = log
    _rpc_handler = rpc_handler

  fun ref connecting(conn: TCPConnection ref, count: U32) =>
    _log(Fine) and _log.log("connecting")
    _rpc_handler.listening()

  fun ref connected(conn: TCPConnection ref) =>
    _log(Fine) and _log.log("connected")
    _rpc_handler.connected()

  fun ref connect_failed(conn: TCPConnection ref) =>
    _log(Fine) and _log.log("connect failed")
    _rpc_handler.connect_failed()

  fun ref auth_failed(conn: TCPConnection ref) =>
    _log(Fine) and _log.log("auth failed")
    _rpc_handler.connect_failed()

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    _log(Fine) and _log.log("received " + data.size().string() + " bytes")
    _rpc_handler.data_received(consume data)
    true

  fun ref closed(conn: TCPConnection ref) =>
    _log(Fine) and _log.log("closed")
    _rpc_handler.closed()
