use "itertools"
use col = "collections"
use per = "collections/persistent"

use json = "../json"
use parser = "../parser"
use ".."

type LineColumnMap is col.MapIs[Node box, (USize, USize)] val
type Path is per.List[Node]
type TraverseError is (Node, String)

primitive SyntaxTree
  fun traverse[S: Any #read](visitor: Visitor[S], state: S, node: Node)
    : (Node, ReadSeq[TraverseError] val)
  =>
    var errors: Array[TraverseError] iso = Array[TraverseError]
    (_, let new_node, errors) = _traverse[S](
      visitor,
      state,
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
    var parent_state' = parent_state
    var errors': Array[TraverseError] iso = consume errors
    (var node_state, errors') = visitor.visit_pre(
      parent_state', node, path, consume errors')
    let num_children = node.children().size()
    if num_children == 0 then
      (parent_state', let result, errors') = visitor.visit_post(
        parent_state', node_state, node, path, consume errors')
      (parent_state', result, consume errors')
    else
      var new_children: (Array[Node] trn | None) = None
      var update_map: (ChildUpdateMap trn | None) = None
      var i: USize = 0
      while i < num_children do
        try
          let child = node.children()(i)?
          let child_name = child.name()
          (node_state, let new_child, errors') = _traverse[S](
            visitor, node_state, child, path.prepend(child), consume errors')

          match (new_children, update_map)
          | (let arr: Array[Node] trn, let um: ChildUpdateMap trn) =>
            match new_child
            | let nc: Node =>
              arr.push(nc)
              um(child) = nc
            end
          | (None, None) =>
            if new_child isnt child then
              let arr: Array[Node] trn =
                Array[Node](node.children().size())
              let um: ChildUpdateMap trn =
                ChildUpdateMap(node.children().size())
              if i > 0 then
                var j: USize = 0
                while j < i do
                  let old_child = node.children()(j)?
                  arr.push(old_child)
                  um(old_child) = old_child
                  j = j + 1
                end
              end

              match new_child
              | let nc:Node =>
                arr.push(nc)
                um(child) = nc
              end

              new_children = consume arr
              update_map = consume um
            end
          end
        end
        i = i + 1
      end

      match (new_children, update_map)
      | (let arr: Array[Node] trn, let um: ChildUpdateMap trn) =>
        (parent_state', let result, errors') = visitor.visit_post(
            parent_state',
            node_state,
            node,
            path,
            consume errors',
            consume arr,
            consume um)
        (parent_state', result, consume errors')
      else
        (parent_state', let result, errors') = visitor.visit_post(
            parent_state', node_state, node, path, consume errors')
        (parent_state', result, consume errors')
      end
    end

  fun add_line_info(node: Node)
    : (Node, Array[parser.Loc] val, ReadSeq[TraverseError] val)
  =>
    match node.src_info().start
    | let start: parser.Loc =>
      let visitor = _UpdateLineInfoVisitor(
        node.src_info().locator, start.segment())
      (let new_node, let errors) =
        traverse[_UpdateLineState](visitor, (0, 0), node)
      let lb: Array[parser.Loc] trn = []
      for loc in visitor.beginnings.values() do lb.push(loc) end
      (new_node, consume lb, consume errors)
    else
      (node, [], [])
    end

type _UpdateLineState is (USize, USize)

class _UpdateLineInfoVisitor is Visitor[_UpdateLineState]
  let beginnings: Array[parser.Loc]
  var locator: parser.Locator
  var segment: parser.Segment
  var line: USize
  var column: USize

  new create(
    locator': parser.Locator,
    segment': parser.Segment)
  =>
    beginnings = Array[parser.Loc]
    locator = locator'
    segment = segment'
    line = 0
    column = 0

  fun ref visit_pre(
    parent_state: _UpdateLineState,
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso)
    : (_UpdateLineState, Array[TraverseError] iso^)
  =>
    let si = node.src_info()
    if si.locator != locator then
      locator = si.locator
      match si.start
      | let si_start: parser.Loc =>
        segment = si_start.segment()
      end
      line = 0
      column = 0
    end
    let node_state = (line, column)

    match node
    | let eol: NodeWith[Trivia] if eol.data().kind is EndOfLineTrivia =>
      if beginnings.size() == 0 then
        match si.start
        | let si_start: parser.Loc =>
          beginnings.push(si_start)
        end
      end
      match si.next
      | let si_next: parser.Loc =>
        beginnings.push(si_next)
      end
      line = line + 1
      column = 0
    else
      if node.children().size() == 0 then
        if beginnings.size() == 0 then
          match si.start
          | let si_start: parser.Loc =>
            beginnings.push(si_start)
          end
        end
        column = column + si.length()
      end
    end

    (node_state, consume errors)

  fun ref visit_post(
    parent_state: _UpdateLineState,
    node_state: _UpdateLineState,
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso,
    new_children: (NodeSeq | None) = None,
    update_map: (ChildUpdateMap | None) = None)
    : (_UpdateLineState^, (Node | None), Array[TraverseError] iso^)
  =>
    (let l, let c) = node_state

    (let nl, let nc) =
      match new_children
      | let nc: NodeSeq if nc.size() > 0 =>
        try
          let last = nc(nc.size() - 1)?
          match (last.src_info().next_line, last.src_info().next_column)
          | (let nl': USize, let nc': USize) =>
            (nl', nc')
          else
            (l, c)
          end
        else
          (l, c)
        end
      else
        match node
        | let eol: NodeWith[Trivia] if eol.data().kind is EndOfLineTrivia =>
          (l + 1, 0)
        else
          (l, c + node.src_info().length())
        end
      end

    let src_info = SrcInfo.from(node.src_info()
      where line' = l, column' = c, next_line' = nl, next_column' = nc)

    let new_node =
      node.clone(where
        src_info' = src_info,
        new_children' = new_children,
        update_map' = update_map)
    (parent_state, new_node, consume errors)
