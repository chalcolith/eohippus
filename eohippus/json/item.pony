use "collections"
use ".."

type Item is (Object box | Sequence box | String | I128 | F64 | Bool)

class Object
  embed _items: Map[String, Item] = _items.create()
  embed _keys: Array[String] = _keys.create()

  new create(items: ReadSeq[(String, Item)] = []) =>
    for (key, value) in items.values() do
      if not _keys.contains(key, {(a, b) => a == b}) then
        _keys.push(key)
      end
      _items(key) = value
    end

  fun contains(key: (String | USize)): Bool =>
    let key' =
      match key
      | let k: String => k
      | let n: USize => n.string()
      end
    _items.contains(key')

  fun apply(key: String): Item ? =>
    _items(key)?

  fun ref update(key: String, value: Item) =>
    _items.update(key, value)

  fun pairs(): Iterator[(String, Item)] =>
    _items.pairs()

  fun get_string(pretty: Bool, indent: String): String iso^ =>
    let indent' =
      if pretty then
        recover val indent + "  " end
      else
        indent
      end
    let result: String iso = String
    result.append("{")
    if pretty then result.append("\n") end
    var first = true
    for key in _keys.values() do
      try
        if first then
          first = false
        else
          result.append(",")
          if pretty then result.append("\n") end
        end
        result.append(indent')
        result.append("\"" + key + "\": ")
        match _items(key)?
        | let obj: Object box =>
          result.append(obj.get_string(pretty, indent'))
        | let seq: Sequence box =>
          result.append(seq.get_string(pretty, indent'))
        | let str: String =>
          result.append("\"" + StringUtil.escape(str) + "\"")
        | let int: I128 =>
          result.append(int.string())
        | let flt: F64 =>
          result.append(flt.string())
        | let bool: Bool =>
          result.append(if bool then "true" else "false" end)
        end
      end
    end
    if pretty then
      result.append("\n")
      result.append(indent)
    end
    result.append("}")
    consume result

  fun string(): String iso^ =>
    get_string(true, "")

class Sequence
  embed _items: Array[Item] = _items.create()

  new create(items: ReadSeq[Item]) =>
    _items.append(items)

  new from_iter(items: Iterator[Item]) =>
    _items.concat(items)

  fun size(): USize => _items.size()

  fun contains(key: USize): Bool =>
    key < _items.size()

  fun apply(i: USize): this->Item ? => _items.apply(i)?

  fun ref update(i: USize, value: Item) ? => _items.update(i, value)?

  fun ref push(item: Item) => _items.push(item)

  fun get_string(pretty: Bool, indent: String): String iso^ =>
    let indent' =
      if pretty then
        recover val indent + "  " end
      else
        indent
      end
    let result: String iso = String
    result.append("[")
    if pretty then result.append("\n") end
    var first = true
    for item in _items.values() do
      if first then
        first = false
      else
        result.append(",")
        if pretty then result.append("\n") end
      end
      if pretty then result.append(indent') end
      match item
      | let obj: this->Object =>
        result.append(obj.get_string(pretty, indent'))
      | let seq: this->Sequence =>
        result.append(seq.get_string(pretty, indent'))
      | let str: String =>
        result.append("\"" + StringUtil.escape(str) + "\"")
      | let int: I128 =>
        result.append(int.string())
      | let flt: F64 =>
        result.append(flt.string())
      | let bool: Bool =>
        result.append(if bool then "true" else "false" end)
      end
    end
    if pretty then
      result.append("\n")
      result.append(indent)
    end
    result.append("]")
    consume result

  fun string(): String iso^ =>
    get_string(true, "")
