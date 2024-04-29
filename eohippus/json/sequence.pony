use "collections"
use ".."

class box Sequence
  embed _items: Array[Item] = _items.create()

  new create(items: Seq[this->Item] box = Array[this->Item]) =>
    _items.append(items)

  new from_vals(items: Seq[Item val] box) =>
    for item in items.values() do
      _items.push(item)
    end

  new from_iter(items: Iterator[this->Item]) =>
    _items.concat(items)

  fun size(): USize => _items.size()

  fun contains(key: USize): Bool =>
    key < _items.size()

  fun apply(i: USize): this->Item ? => _items.apply(i)?

  fun values(): Iterator[this->Item] => _items.values()

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
    if _items.size() > 0 then
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
    result.append("]")
    consume result

  fun string(): String iso^ =>
    get_string(true, "")
