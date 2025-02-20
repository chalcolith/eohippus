use "itertools"

use json = "../../../json"

interface val PublishDiagnosticsParams is NotificationParams
  fun val uri(): String
  fun val version(): (I128 | None) => None
  fun val diagnostics(): Array[Diagnostic] val

  fun val get_json(): json.Item =>
    let props = [ as (String, json.Item): ("uri", uri()) ]
    match version()
    | let n: I128 =>
      props.push(("version", n))
    end
    props.push(
      ( "diagnostics"
      , recover val
          json.Sequence.from_iter[Diagnostic](
            diagnostics().values(), { (diag) => diag.get_json() })
        end ))
    json.Object(props)

primitive DiagnosticError
  fun apply(): I128 => 1

primitive DiagnosticWarning
  fun apply(): I128 => 2

primitive DiagnosticInformation
  fun apply(): I128 => 3

primitive DiagnosticHint
  fun apply(): I128 => 4

type DiagnosticSeverity is
  ( DiagnosticError
  | DiagnosticWarning
  | DiagnosticInformation
  | DiagnosticHint )

primitive DiagnosticTagUnnecessary
  fun apply(): I128 => 1

primitive DiagnosticTagDeprecated
  fun apply(): I128 => 2

type DiagnosticTag is (DiagnosticTagUnnecessary | DiagnosticTagDeprecated)

interface val DiagnosticRelatedInformation
  fun val location(): Location
  fun val message(): String

  fun val get_json(): json.Item =>
    json.Object(
      [ as (String, json.Item):
        ("location", location().get_json())
        ("message", message()) ])

interface val Diagnostic
  fun val range(): Range
  fun val severity(): (DiagnosticSeverity | None)
  fun val code(): (I128 | String | None) => None
  fun val codeDescription(): (CodeDescription | None) => None
  fun val source(): (String | None) => "eohippus pony tools"
  fun val message(): String
  fun val tags(): (Array[DiagnosticTag] val | None) => None
  fun val relatedInformation()
    : (Array[DiagnosticRelatedInformation] val | None)
  =>
    None
  fun val data(): (json.Item | None) => None

  fun val get_json(): json.Item =>
    let props = [ as (String, json.Item): ("range", range().get_json()) ]
    match severity()
    | let s: DiagnosticSeverity =>
      props.push(("severity", s()))
    end
    match code()
    | let item: (I128 | String) =>
      props.push(("code", item))
    end
    match codeDescription()
    | let cd: CodeDescription =>
      props.push(("codeDescription", cd.get_json()))
    end
    match source()
    | let str: String =>
      props.push(("source", str))
    end
    props.push(("message", message()))
    match tags()
    | let tags_arr: Array[DiagnosticTag] val =>
      let seq =
        recover val
          json.Sequence.from_iter[DiagnosticTag](
            tags_arr.values(), {(t) => t() })
        end
      props.push(("tags", seq))
    end
    match relatedInformation()
    | let ri_arr: Array[DiagnosticRelatedInformation] val =>
      let seq =
        json.Sequence.from_iter[DiagnosticRelatedInformation](
          ri_arr.values(), {(ri) => ri.get_json() })
      props.push(("relatedInformation", seq))
    end
    match data()
    | let d: json.Item =>
      props.push(("data", d))
    end
    json.Object(props)

interface val CodeDescription
  fun val href(): String

  fun val get_json(): json.Item =>
    json.Object([ as (String, json.Item): ("href", href()) ])
