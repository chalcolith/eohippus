use json = "../../json"
use rpc = "../../language_server/rpc"

actor TestInputStream is InputStream
  var _valid: Bool = false
  var _notify: (InputNotify iso | None) = None

  be apply(notify: (InputNotify iso | None), chunk_size: USize = 32) =>
    _notify = consume notify
    _valid = true

  be dispose() =>
    if _valid then
      match _notify
      | let notify: InputNotify iso =>
        notify.dispose()
      end
      _valid = false
    end

  be write(data: (String iso | Array[U8] iso)) =>
    if not _valid then return end
    match _notify
    | let notify: InputNotify iso =>
      match data
      | let str: String =>
        notify(str.clone().iso_array())
      | let arr: Array[U8] iso =>
        notify(consume arr)
      end
    end

  be send_message(obj: json.Object val) =>
    if not _valid then return end
    let body = obj.get_string(false)
    let content_length = body.size()
    write(
      "Content-Length:" + content_length.string() + "\r\n" +
      "Content-Type:" + rpc.JsonRpc.mime_type() + "; charset=" +
        rpc.JsonRpc.charset() + "\r\n" +
      "\r\n".clone() +
      (consume body))

actor TestOutputStream is OutStream
  let _notify: ({(String)} val | None)

  new create(notify: ({(String)} val | None) = None) =>
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
      match _notify
      | let notify: {(String)} val =>
        notify(str)
      end
    | let arr: Array[U8] val =>
      match _notify
      | let notify: {(String)} val =>
        notify(String.from_array(arr))
      end
    end

  be writev(data: ByteSeqIter val) =>
    for chunk in data.values() do
      write(chunk)
    end

  be flush() =>
    None
