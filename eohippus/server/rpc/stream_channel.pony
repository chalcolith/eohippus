use "logger"

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

    _rpc_handler.listening()
    _input(
      object iso is InputNotify
        fun ref apply(data: Array[U8] iso) =>
          _rpc_handler.data_received(consume data)

        fun ref dispose() =>
          _valid = false
          _rpc_handler.closed()
      end,
      2048)
    _rpc_handler.connected()

  fun ref write(data: (String val | Array[U8] val)) =>
    if _valid then
      _output.write(data)
    end

  fun ref flush() =>
    if _valid then
      _output.flush()
    end

  fun ref close() =>
    _input.dispose()
