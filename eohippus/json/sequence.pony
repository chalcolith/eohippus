use "collections"
use "itertools"
use ".."

class Sequence
  embed _items: Array[Item]

  new create(items: (ReadSeq[Item] | None) = None) =>
    match items
    | let items': ReadSeq[Item] =>
      _items = _items.create(items'.size())
      _items.append(items')
    else
      _items = Array[Item](0)
    end

  new from_iter[T](items: Iterator[T], f: {(T!): Item } box) =>
    _items = Array[Item]
    Iter[T](items).map[Item](f).collect(_items)

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
