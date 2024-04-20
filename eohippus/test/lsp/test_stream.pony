
actor TestInputStream is InputStream
  var _notify: (InputNotify iso | None) = None

  be apply(notify: (InputNotify iso | None), chunk_size: USize = 32) =>
    _notify = consume notify

  be dispose() =>
    match _notify
    | let notify: InputNotify iso =>
      notify.dispose()
    end

  be write(data: (String iso | Array[U8] iso)) =>
    match _notify
    | let notify: InputNotify iso =>
      match data
      | let str: String =>
        notify(str.clone().iso_array())
      | let arr: Array[U8] iso =>
        notify(consume arr)
      end
    end

interface TestOutputNotify
  be write_output(stream: TestOutputStream tag, str: String)

actor TestOutputStream is OutStream
  let _notify: TestOutputNotify tag

  new create(notify: TestOutputNotify tag) =>
    _notify = notify

  be print(data: (String | Array[U8] val)) =>
    match data
    | let arr: Array[U8] val =>
      write(String.from_array(arr) + "\r\n")
    | let str: String =>
      write(str + "\r\n")
    end

  be printv(data: ByteSeqIter val) =>
    for line in data.values() do
      print(line)
    end

  be write(data: (String | Array[U8] val)) =>
    match data
    | let str: String =>
      _notify.write_output(this, str)
    | let arr: Array[U8] val =>
      _notify.write_output(this, String.from_array(arr))
    end

  be writev(data: ByteSeqIter val) =>
    for chunk in data.values() do
      write(chunk)
    end

  be flush() =>
    None
