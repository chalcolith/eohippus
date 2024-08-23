use "collections"
use "itertools"
use ".."

class box Object
  embed _items: Array[(String, Item)] = _items.create()

  new create(items: ReadSeq[(String, Item)] box = Array[(String, Item)]) =>
    for (key, value) in items.values() do
      _items.push((key, value))
    end

  fun contains(key: (String | USize)): Bool =>
    let key' =
      match key
      | let k: String => k
      | let n: USize => n.string()
      end
    for (k, _) in _items.values() do
      if k == key' then
        return true
      end
    end
    false

  fun apply(key: String): this->Item ? =>
    for (k, v) in _items.values() do
      if k == key then
        return v
      end
    end
    error

  fun ref update(key: String, value: Item) =>
    var i: USize = 0
    while i < _items.size() do
      try
        if _items(i)?._1 == key then
          _items(i)? = (key, value)
          return
        end
      end
      i = i + 1
    end
    _items.push((key, value))

  fun pairs(): Iterator[(String, this->Item)] =>
    _items.values()

  fun get_string(pretty: Bool, indent: String = ""): String iso^ =>
    let indent' =
      if pretty then
        recover val indent + "  " end
      else
        indent
      end
    let result: String iso = String
    result.append("{")
    if _items.size() > 0 then
      if pretty then result.append("\n") end
      var first = true
      for (key, value) in _items.values() do
        if first then
          first = false
        else
          result.append(",")
          if pretty then result.append("\n") end
        end
        result.append(indent')
        result.append("\"" + key + "\":")
        if pretty then result.append(" ") end
        match value
        | let obj: this->Object box =>
          result.append(obj.get_string(pretty, indent'))
        | let seq: this->Sequence box =>
          result.append(seq.get_string(pretty, indent'))
        | let str: this->String box =>
          result.append("\"" + StringUtil.escape(str) + "\"")
        | let int: I128 =>
          result.append(int.string())
        | let flt: F64 =>
          result.append(flt.string())
        | let bool: Bool =>
          result.append(if bool then "true" else "false" end)
        | let null: Null =>
          result.append("null")
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
