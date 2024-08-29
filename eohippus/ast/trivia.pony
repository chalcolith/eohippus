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

  fun val clone(updates: ChildUpdateMap): NodeData =>
    this

  fun add_json_props(node: Node box, props: Array[(String, json.Item)]) =>
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

primitive ParseTrivia
  fun apply(obj: json.Object, children: NodeSeq): (Trivia | String) =>
    let kind: TriviaKind =
      match try obj("kind")? end
      | "LineCommentTrivia" =>
        LineCommentTrivia
      | "NestedCommentTrivia" =>
        NestedCommentTrivia
      | "WhiteSpaceTrivia" =>
        WhiteSpaceTrivia
      | "EndOfLineTrivia" =>
        EndOfLineTrivia
      | "EndOfFileTrivia" =>
        EndOfFileTrivia
      else
        return "Trivia.kind must be a valid trivia kind"
      end
    let string =
      match try obj("string")? end
      | let s: String box =>
        s
      else
        return "Trivia.string must be a string"
      end
    Trivia(kind, string.clone())
