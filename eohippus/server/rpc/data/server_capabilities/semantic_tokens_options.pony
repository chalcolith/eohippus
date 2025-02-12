use json = "../../../../json"

use ".."

interface val SemanticTokensOptions is (WorkDoneProgressOptions & ResultData)
  fun val legend(): SemanticTokensLegend
  fun val range(): (Bool | json.Object | None)
  fun val full(): (Bool | SemanticTokensFullOptions | None)

  fun val get_json_props(): Array[(String, json.Item)] =>
    let props = [ as (String, json.Item): ("legend", legend().get_json()) ]
    match workDoneProgress()
    | let bool: Bool =>
      props.push(("workDoneProgress", bool))
    end
    match range()
    | let bool: Bool =>
      props.push(("range", bool))
    | let obj: json.Object =>
      props.push(("range", obj))
    end
    match full()
    | let bool: Bool =>
      props.push(("full", bool))
    | let fo: SemanticTokensFullOptions =>
      props.push(("full", fo.get_json()))
    end
    props

  fun val get_json(): json.Item =>
    json.Object(get_json_props())

interface val SemanticTokensRegistrationOptions is
  ( SemanticTokensOptions &
    TextDocumentRegistrationOptions &
    StaticRegistrationOptions )
  fun val get_json(): json.Item =>
    let props = Array[(String, json.Item)]
    match id()
    | let str: String =>
      props.push(("id", str))
    end
    match documentSelector()
    | let ds: DocumentSelector =>
      let seq =
        json.Sequence.from_iter[DocumentFilter](
          ds.values(), {(filter) => filter.get_json() })
      props.push(("documentSelector", seq))
    end
    props.append(get_json_props())
    json.Object(props)

interface val SemanticTokensLegend
  fun val tokenTypes(): Array[String] val
  fun val tokenModifiers(): Array[String] val

  fun val get_json(): json.Item =>
    json.Object(
      [ as (String, json.Item):
        ("tokenTypes", recover val json.Sequence(tokenTypes()) end)
        ("tokenModifiers", recover val json.Sequence(tokenModifiers()) end) ])

interface val SemanticTokensFullOptions
  fun val delta(): (Bool | None)

  fun val get_json(): json.Item =>
    let props = Array[(String, json.Item)]
    match delta()
    | let bool: Bool =>
      props.push(("delta", bool))
    end
    json.Object(props)

primitive SemanticTokens
  fun apply(): Array[String] val =>
    [ "type"
      "class"
      "interface"
      "struct"
      "typeParameter"
      "parameter"
      "variable"
      "function"
      "method"
      "keyword"
      "comment"
      "string"
      "number"
      "operator"
      "decorator" ]

primitive SemanticModifiers
  fun apply(): Array[String] val =>
    [ "documentation" ]
