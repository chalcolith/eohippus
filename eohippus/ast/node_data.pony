use json = "../json"

trait val NodeData
  fun name(): String

  fun add_json_props(props: Array[(String, json.Item)])

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ?

  fun _child(old_child: Node, old_children: NodeSeq, new_children: NodeSeq)
    : Node ?
  =>
    var i: USize = 0
    while i < old_children.size() do
      if old_child is old_children(i)? then
        return new_children(i)?
      end
      i = i + 1
    end
    error

  fun _child_with[T: NodeData val](
    old_child: NodeWith[T],
    old_children: NodeSeq,
    new_children: NodeSeq)
    : NodeWith[T] ?
  =>
    var i: USize = 0
    while i < old_children.size() do
      if old_child is old_children(i)? then
        return new_children(i)? as NodeWith[T]
      end
      i = i + 1
    end
    error

  fun _child_or_none(
    old_child: (Node | None),
    old_children: NodeSeq,
    new_children: NodeSeq)
    : (Node | None) ?
  =>
    match old_child
    | let old_child': Node =>
      var i: USize = 0
      while i < old_children.size() do
        if old_child' is old_children(i)? then
          return new_children(i)?
        end
        i = i + 1
      end
    end
    None

  fun _child_with_or_none[T: NodeData val](
    old_typed_child: (NodeWith[T] | None),
    old_children: NodeSeq,
    new_children: NodeSeq)
    : (NodeWith[T] | None) ?
  =>
    match old_typed_child
    | let old_typed_child': NodeWith[T] =>
      var i: USize = 0
      while i < old_children.size() do
        if old_typed_child' is old_children(i)? then
          return new_children(i)? as NodeWith[T]
        end
        i = i + 1
      end
    end
    None

  fun _child_seq_with[T: NodeData val](
    old_typed_children: NodeSeqWith[T],
    old_children: NodeSeq,
    new_children: NodeSeq)
    : NodeSeqWith[T] ?
  =>
    let result: Array[NodeWith[T]] trn = Array[NodeWith[T]](
      old_typed_children.size())
    for old_typed_child in old_typed_children.values() do
      var i: USize = 0
      while i < old_children.size() do
        if old_typed_child is old_children(i)? then
          result.push(new_children(i)? as NodeWith[T])
          break
        end
        i = i + 1
      end
      if i == old_children.size() then error end
    end
    consume result

trait val NodeDataWithValue[V: Any val] is NodeData
  fun value(): V
