use json = "../../../json"

interface val PublishDiagnosticsParams is NotificationParams
  fun val uri(): String
  fun val version(): (I128 | None) => None
  fun val diagnostics(): Array[Diagnostic] val

  fun val get_json(): json.Item val =>
    recover val
      let props = [ as (String, json.Item): ("uri", uri()) ]
      match version()
      | let n: I128 =>
        props.push(("version", n))
      end
      let diag_items = Array[json.Item val]
      for diag in diagnostics().values() do
        diag_items.push(diag.get_json())
      end
      props.push(("diagnostics", json.Sequence(diag_items)))
      json.Object(props)
    end

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

  fun val get_json(): json.Item val =>
    recover val
      json.Object(
        [ as (String, json.Item):
          ("location", location().get_json())
          ("message", message()) ])
    end

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
  fun val data(): (json.Item val | None) => None

  fun val get_json(): json.Item val =>
    recover val
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
        let items = Array[json.Item]
        for t in tags_arr.values() do
          items.push(t())
        end
        props.push(("tags", json.Sequence(items)))
      end
      match relatedInformation()
      | let ri_arr: Array[DiagnosticRelatedInformation] val =>
        let items = Array[json.Item]
        for ri in ri_arr.values() do
          items.push(ri.get_json())
        end
        props.push(("relatedInformation", json.Sequence(items)))
      end
      match data()
      | let d: json.Item =>
        props.push(("data", d))
      end
      json.Object(props)
    end

interface val CodeDescription
  fun val href(): String

  fun val get_json(): json.Item val =>
    recover val
      json.Object([ as (String, json.Item): ("href", href()) ])
    end
