use "collections"
use ".."

primitive Null
  fun string(): String iso^ => "null".clone()

type Item is (Object | Sequence | String box | I128 | F64 | Bool | Null)

primitive Clone
  fun apply(item: Item): Item val =>
    match item
    | let obj: Object =>
      let props: Seq[(String, Item val)] trn = Array[(String, Item val)]
      for (k, v) in obj.pairs() do
        props.push((k, Clone(v)))
      end
      let props': Seq[(String, Item val)] val = consume props
      recover Object.from_vals(props') end
    | let seq: Sequence =>
      let items: Seq[Item val] trn = Array[Item val]
      for v in items.values() do
        items.push(Clone(v))
      end
      let items': Seq[Item val] val = consume items
      recover Sequence.from_vals(items') end
    | let str: String box =>
      str.clone()
    | let int: I128 =>
      int
    | let float: F64 =>
      float
    | let bool: Bool =>
      bool
    | Null =>
      Null
    end
