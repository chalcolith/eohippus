use "logger"

interface Channel
  fun ref write(data: (String val | Array[U8] val))
  fun ref flush()
  fun ref close()
