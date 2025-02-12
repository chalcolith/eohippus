use "collections"
use ".."

primitive Null
  fun string(): String iso^ => "null".clone()

type Item is (Object box | Sequence box | String box | I128 | F64 | Bool | Null)

primitive Clone
  fun apply(item: Item)
    : (Object ref | Sequence ref | String ref | I128 | F64 | Bool | Null)
  =>
    match item
    | let obj: Object box =>
      let props = Array[(String, Item)]
      for (k, v) in obj.pairs() do
        props.push((k, Clone(v)))
      end
      Object(props)
    | let seq: Sequence box =>
      Sequence.from_iter[Item](seq.values(), {(i) => Clone(i) })
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
