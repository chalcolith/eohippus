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
  let kind: TriviaKind
  let string: String

  new val create(kind': TriviaKind, string': String) =>
    kind = kind'
    string = string'

  fun name(): String => "Trivia"

  fun add_json_props(props: Array[(String, json.Item)]) =>
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
