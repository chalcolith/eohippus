use "itertools"
use col = "collections"
use per = "collections/persistent"

use json = "../json"
use parser = "../parser"
use ".."

type LineColumnMap is col.MapIs[Node box, (USize, USize)] val
type Path is per.List[Node]
type TraverseError is (Node, String)

class SyntaxTree
  var root: Node
  var line_beginnings: Array[parser.Loc] val
  var traverse_errors: ReadSeq[TraverseError] val

  new create(root': Node, update_lines: Bool = true) =>
    root = root'
    if update_lines then
      match root.src_info().start
      | let root_start: parser.Loc =>
        let visitor = _UpdateLineInfoVisitor(
          root.src_info().locator, root_start.segment())
        (let new_root, let errors) =
          traverse[(USize, USize)](visitor, root)
        match new_root
        | let new_root': Node =>
          root = new_root'
        end
        let lb: Array[parser.Loc] trn =
          Array[parser.Loc](visitor.beginnings.size())
        for loc in visitor.beginnings.values() do
          lb.push(loc)
        end
        line_beginnings = consume lb
        traverse_errors = consume errors
      else
        line_beginnings = Array[parser.Loc]
        traverse_errors = Array[TraverseError]
      end
    else
      line_beginnings = Array[parser.Loc]
      traverse_errors = Array[TraverseError]
    end

  fun tag traverse[S](visitor: Visitor[S], node: Node)
    : (Node, ReadSeq[TraverseError] val)
  =>
    var errors: Array[TraverseError] iso = Array[TraverseError]
    (let new_node, errors) = _traverse[S](
      visitor,
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

  fun tag _indent(n: USize): String =>
    recover val
      let s = String(n)
      var i: USize = 0
      while i < n do
        s.append("  ")
        i = i + 1
      end
      s
    end

  fun tag _traverse[S](
    visitor: Visitor[S],
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso)
    : ((Node | None), Array[TraverseError] iso^)
  =>
    var errors': Array[TraverseError] iso = consume errors
    (let node_state, errors') = visitor.visit_pre(node, path, consume errors')
    let num_children = node.children().size()
    if num_children == 0 then
      (let result, errors') = visitor.visit_post(
        consume node_state, node, path, consume errors')
      (result, consume errors')
    else
      var new_children: (Array[Node] trn | None) = None
      var update_map: (ChildUpdateMap trn | None) = None
      var i: USize = 0
      while i < num_children do
        try
          let child = node.children()(i)?
          let child_name = child.name()
          (let new_child, errors') = _traverse[S](
            visitor, child, path.prepend(child), consume errors')

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
        (let result, errors') = visitor.visit_post(
            consume node_state,
            node,
            path,
            consume errors',
            consume arr,
            consume um)
        (result, consume errors')
      else
        (let result, errors') = visitor.visit_post(
            consume node_state, node, path, consume errors')
        (result, consume errors')
      end
    end

class _UpdateLineInfoVisitor is Visitor[(USize, USize)]
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

  fun ref visit_pre(node: Node, path: Path, errors: Array[TraverseError] iso)
    : ((USize, USize), Array[TraverseError] iso^)
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
    let state = (line, column)

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

    (state, consume errors)

  fun ref visit_post(
    pre_state: (USize, USize),
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso,
    new_children: (NodeSeq | None) = None,
    update_map: (ChildUpdateMap | None) = None)
    : ((Node | None), Array[TraverseError] iso^)
  =>
    (let l, let c) = pre_state
    let src_info = SrcInfo.from(node.src_info()
      where line' = l, column' = c)

    let new_node =
      node.clone(where
        src_info' = src_info,
        new_children' = new_children,
        update_map' = update_map)
    (new_node, consume errors)
