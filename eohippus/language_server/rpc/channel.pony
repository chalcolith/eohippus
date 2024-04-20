use "logger"

interface Channel
  fun valid(): Bool
  fun write(data: (String val | Array[U8] val))
  fun flush()
  fun close()

// class TcpChannel is Channel

class StreamChannel is Channel
  let _log: Logger[String]
  let _input: InputStream
  let _output: OutStream
  let _rpc_handler: Handler
  var _valid: Bool

  new create(
    log: Logger[String],
    input: InputStream,
    output: OutStream,
    rpc_handler: Handler)
  =>
    _log = log
    _input = input
    _output = output
    _rpc_handler = rpc_handler
    _valid = true

    _input(
      object iso is InputNotify
        fun ref apply(data: Array[U8] iso) =>
          _rpc_handler.data_received(consume data)

        fun ref dispose() =>
          _valid = false
          _rpc_handler.channel_closed()
      end)
    _rpc_handler.connect_succeeded()

  fun valid(): Bool =>
    _valid

  fun write(data: (String val | Array[U8] val)) =>
    if _valid then
      _output.write(data)
    end

  fun flush() =>
    if _valid then
      _output.flush()
    end

  fun close() =>
    _input.dispose()
