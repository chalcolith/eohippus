use "collections"
use ".."

type Item is (Object box | Sequence box | String | F64 | Bool)

class Object
  embed _items: Map[String, Item] = _items.create()
  embed _keys: Array[String] = _keys.create()

  new create(items: ReadSeq[(String, Item)]) =>
    for (key, value) in items.values() do
      if not _keys.contains(key, {(a, b) => a == b}) then
        _keys.push(key)
      end
      _items(key) = value
    end

  fun apply(key: String): Item ? =>
    _items(key)?

  fun ref update(key: String, value: Item) =>
    _items.update(key, value)

  fun pairs(): Iterator[(String, Item)] =>
    _items.pairs()

  fun _get_string(indent: String): String iso^ =>
    let indent' = recover val indent + "  " end
    let str: String iso = String
    str.append("{\n")
    var first = true
    for key in _keys.values() do
      try
        if first then
          first = false
        else
          str.append(",\n")
        end
        str.append(indent')
        str.append("\"" + key + "\": ")
        match _items(key)?
        | let obj: Object box =>
          str.append(obj._get_string(indent'))
        | let seq: Sequence box =>
          str.append(seq._get_string(indent'))
        | let str': String =>
          str.append("\"" + StringUtil.escape(str') + "\"")
        | let num: F64 =>
          str.append(num.string())
        | let bol: Bool =>
          str.append(if bol then "true" else "false" end)
        end
      end
    end
    str.append("\n")
    str.append(indent)
    str.append("}")
    consume str

  fun string(): String iso^ =>
    _get_string("")

class Sequence
  embed _items: Array[Item] = _items.create()

  new create(items: ReadSeq[Item]) =>
    for item in items.values() do
      _items.push(item)
    end

  fun size(): USize => _items.size()

  fun apply(i: USize): this->Item ? => _items.apply(i)?

  fun ref update(i: USize, value: Item) ? => _items.update(i, value)?

  fun _get_string(indent: String): String iso^ =>
    let indent' = recover val indent + "  " end
    let str: String iso = String
    str.append("[\n")
    var first = true
    for item in _items.values() do
      if first then
        first = false
      else
        str.append(",\n")
      end
      str.append(indent')
      match item
      | let obj: this->Object =>
        str.append(obj._get_string(indent'))
      | let seq: this->Sequence =>
        str.append(seq._get_string(indent'))
      | let str': String =>
        str.append("\"" + StringUtil.escape(str') + "\"")
      | let num: F64 =>
        str.append(num.string())
      | let bol: Bool =>
        str.append(if bol then "true" else "false" end)
      end
    end
    str.append("\n")
    str.append(indent)
    str.append("]")
    consume str

  fun string(): String iso^ =>
    _get_string("")
