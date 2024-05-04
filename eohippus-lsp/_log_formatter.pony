use "format"
use "logger"
use "time"

class _LogFormatter is LogFormatter
  fun apply(message: String, loc: SourceLoc): String =>
    (let seconds, let nanos) = Time.now()
    let millis =
      recover val
        Format.int[I64](nanos / 1_000_000 where width = 3, fill = '0')
      end
    let stamp =
      try
        PosixDate(seconds, nanos).format("%Y-%m-%d %H:%M:%S")?
      else
        "?"
      end

    var fname = loc.file()
    let line = recover val loc.line().string() end

    fname =
      try
        let index = USize.from[ISize](fname.rfind("server")?)
        fname.trim(index + 16)
      else
        try
          let index = USize.from[ISize](fname.rfind("eohippus")?)
          fname.trim(index + 9)
        else
          fname
        end
      end

    let buf: String trn = String
    buf.append("[")
    buf.append(stamp)
    buf.append(".")
    buf.append(millis)
    buf.append("Z] ")
    buf.append(fname)
    buf.append(":")
    buf.append(line)
    buf.append(": ")
    buf.append(message)
    consume buf
