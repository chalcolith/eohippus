use json = "../json"
use parser = "../parser"

class val SyntaxTree
  let root: Node
  let line_beginnings: Array[parser.Loc]

  new val create(root': Node) =>
    root = root'
    line_beginnings = Array[parser.Loc]
    _get_line_beginnings(root', line_beginnings, true)

  fun tag _get_line_beginnings(
    node: Node,
    arr: Array[parser.Loc],
    need_first: Bool)
  =>
    let jj = node.get_json()
    let name =
      match jj
      | let obj: json.Object val =>
        try obj("name")? as String else "?" end
      | let str: Stringable =>
        str.string()
      end
    let text = jj.string()

    let src_info = node.src_info()
    let num_children = node.children().size()

    match node
    | let eol: NodeWith[Trivia] if eol.data().kind is EndOfLineTrivia =>
      if need_first then
        arr.push(node.src_info().start)
      end
      arr.push(eol.src_info().next)
    else
      if need_first and (node.children().size() == 0) then
        arr.push(node.src_info().start)
      end

      var i: USize = 0
      for child in node.children().values() do
        _get_line_beginnings(child, arr, need_first and (i == 0))
        i = i + 1
      end
    end
