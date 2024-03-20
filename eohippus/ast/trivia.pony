use json = "../json"

primitive LineCommentTrivia
primitive NestedCommentTrivia
primitive WhiteSpaceTrivia
primitive EndOfLineTrivia
primitive EndOfFileTrivia

type TriviaKind is
  ( LineCommentTrivia
  | NestedCommentTrivia
  | WhiteSpaceTrivia
  | EndOfLineTrivia
  | EndOfFileTrivia )

class val Trivia is NodeData
  """Contains comments and white space."""

  let kind: TriviaKind
  let string: String

  new val create(kind': TriviaKind, string': String) =>
    kind = kind'
    string = string'

  fun name(): String => "Trivia"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(node: Node, props: Array[(String, json.Item)]) =>
    let kind_str =
      match kind
      | LineCommentTrivia => "LineCommentTrivia"
      | NestedCommentTrivia => "NestedCommentTrivia"
      | WhiteSpaceTrivia => "WhiteSpaceTrivia"
      | EndOfLineTrivia => "EndOfLineTrivia"
      | EndOfFileTrivia => "EndOfFileTrivia"
      end
    props.push(("kind", kind_str))
    props.push(("string", string))
