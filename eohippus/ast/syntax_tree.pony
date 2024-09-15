use "itertools"
use col = "collections"
use per = "collections/persistent"

use json = "../json"
use parser = "../parser"
use ".."

type ChildUpdateMap is col.MapIs[Node, Node] val
type Path is per.List[Node]
type TraverseError is (Node, String)

primitive SyntaxTree
  fun traverse[S: Any #read](visitor: Visitor[S], initial_state: S, node: Node)
    : (Node, ReadSeq[TraverseError] val)
  =>
    var errors: Array[TraverseError] iso = Array[TraverseError]
    (_, let new_node, errors) = _traverse[S](
      visitor,
      initial_state,
      node,
      per.Cons[Node](node, per.Nil[Node]),
      consume errors)
    match new_node
    | let n: Node =>
      (n, consume errors)
    else
      errors.push((node, "traversal deleted the node"))
      (node, errors)
    end

  fun _traverse[S: Any #read](
    visitor: Visitor[S],
    parent_state: S,
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso)
    : (S, (Node | None), Array[TraverseError] iso^)
  =>
    var errors': Array[TraverseError] iso = consume errors
    (var node_state, errors') = visitor.visit_pre(
      parent_state, node, path, consume errors')

    let num_children = node.children().size()
    if num_children == 0 then
      (node_state, let new_node, errors') = visitor.visit_post(
        node_state, node, path, consume errors', [], None, None)
      (node_state, new_node, consume errors')
    else
      var new_children: (Array[Node] trn | None) = None
      var update_map: (ChildUpdateMap trn | None) = None
      let child_states = Array[S](node.children().size())

      var i: USize = 0
      for child in node.children().values() do
        (let child_state, let new_child, errors') = _traverse[S](
          visitor, node_state, child, path.prepend(child), consume errors')

        if new_child isnt None then
          child_states.push(child_state)
        end

        // we inside-out these matches, because we still want to populate
        // new_children if there's a None new child, to record that the children
        // changed
        match (new_children, update_map)
        | (let nc: Array[Node] trn, let um: ChildUpdateMap trn) =>
          match new_child
          | let new_child': Node =>
            nc.push(new_child')
            um(child) = new_child'
          end
        | (None, None) if new_child isnt child =>
          let nc: Array[Node] trn = Array[Node](node.children().size())
          let um: ChildUpdateMap trn = ChildUpdateMap(node.children().size())

          // if we haven't seen any changes until now, fill up our new_children
          // with the old ones
          for j in col.Range(0, i) do
            try
              let old_child = node.children()(j)?
              nc.push(old_child)
              um(old_child) = old_child
            end
          end

          match new_child
          | let new_child': Node =>
            nc.push(new_child')
            um(child) = new_child'
          end

          new_children = consume nc
          update_map = consume um
        end
        i = i + 1
      end

      match (new_children, update_map)
      | (let nc: Array[Node] trn, let um: ChildUpdateMap trn) =>
        (node_state, let new_node, errors') = visitor.visit_post(
            node_state,
            node,
            path,
            consume errors',
            if child_states.size() > 0 then child_states end,
            consume nc,
            consume um)
        (node_state, new_node, consume errors')
      else
        (node_state, let new_node, errors') = visitor.visit_post(
          node_state,
          node, path,
          consume errors',
          if child_states.size() > 0 then consume child_states end,
          None,
          None)
        (node_state, new_node, consume errors')
      end
    end

  fun add_line_info(node: Node)
    : (Node, Array[parser.Loc] val, ReadSeq[TraverseError] val)
  =>
    match node.src_info().start
    | let start: parser.Loc =>
      let visitor = _LineInfoVisitor(
        node.src_info().locator, start.segment())
      (let new_node, let errors) =
        traverse[_UpdateLineState](visitor, (0, 0), node)
      let lb: Array[parser.Loc] trn =
        Array[parser.Loc](visitor.beginnings.size())
      for loc in visitor.beginnings.values() do lb.push(loc) end
      (new_node, consume lb, consume errors)
    else
      (node, [], [ (node, "node has no start Loc from parser") ])
    end
