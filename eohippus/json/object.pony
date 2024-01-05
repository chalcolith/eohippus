use "collections"
use ".."

class Object
  embed _items: Map[String, Item] = _items.create()

  new create(items: Seq[(String, Item)] = Array[(String, Item)]) =>
    for (key, value) in items.values() do
      _items(key) = value
    end

  fun contains(key: (String | USize)): Bool =>
    let key' =
      match key
      | let k: String => k
      | let n: USize => n.string()
      end
    _items.contains(key')

  fun apply(key: String): this->Item ? =>
    _items(key)?

  fun ref update(key: String, value: Item) =>
    _items.update(key, value)

  fun pairs(): Iterator[(String, this->Item)] =>
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
    let keys = _items.keys()
    if keys.has_next() then
      if pretty then result.append("\n") end
      var first = true
      for key in keys do
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
          | let str: String box =>
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
    end
    result.append("}")
    consume result

  fun string(): String iso^ =>
    get_string(true, "")
