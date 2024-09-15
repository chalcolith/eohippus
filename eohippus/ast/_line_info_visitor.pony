use parser = "../parser"

type _UpdateLineState is (USize, USize)

class _LineInfoVisitor is Visitor[_UpdateLineState]
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
    node_state: _UpdateLineState,
    node: Node,
    path: Path,
    errors: Array[TraverseError] iso,
    child_states: (ReadSeq[_UpdateLineState] | None),
    new_children: (NodeSeq | None) = None,
    update_map: (ChildUpdateMap | None) = None)
    : (_UpdateLineState^, (Node | None), Array[TraverseError] iso^)
  =>
    // the start line and column of our node
    (let l, let c) = node_state

    // now find the next (line, column)
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
    (node_state, new_node, consume errors)
