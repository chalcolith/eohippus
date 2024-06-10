use json = "../../../../json"

use ".."

interface val TextDocumentClientCapabilities
  fun val definition(): (DefinitionClientCapabilities | None)
  fun val publishDiagnostics(): (PublishDiagnosticsClientCapabilities | None)

primitive ParseTextDocumentClientCapabilities
  fun apply(obj: json.Object val)
    : (TextDocumentClientCapabilities | String)
  =>
    let definition' =
      try
        match obj("definition")?
        | let d_obj: json.Object val =>
          match ParseDefinitionClientCapabilities(d_obj)
          | let d: DefinitionClientCapabilities =>
            d
          | let err: String =>
            return err
          end
        else
          return "textDocument.definition must be a JSON object"
        end
      end
    let publishDiagnostics' =
      try
        match obj("publishDiagnostics")?
        | let pd_obj: json.Object val =>
          match ParsePublishDiagnosticsClientCapabilities(pd_obj)
          | let pd: PublishDiagnosticsClientCapabilities =>
            pd
          | let err: String =>
            return err
          end
        else
          return "textDocument.publishDiagnostics must be a JSON object"
        end
      end
    object val is TextDocumentClientCapabilities
      fun val definition(): (DefinitionClientCapabilities | None) => definition'
      fun val publishDiagnostics()
        : (PublishDiagnosticsClientCapabilities | None)
      =>
        publishDiagnostics'
    end

interface val PublishDiagnosticsClientCapabilities
  fun val relatedInformation(): (Bool | None)
  fun val tagSupport(): (TagSupport | None)
  fun val versionSupport(): (Bool | None)
  fun val codeDescriptionSupport(): (Bool | None)
  fun val dataSupport(): (Bool | None)

primitive ParsePublishDiagnosticsClientCapabilities
  fun apply(obj: json.Object val)
    : (PublishDiagnosticsClientCapabilities | String)
  =>
    let relatedInformation' =
      match try obj("relatedInformation")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "publishDiagnostics.relatedInformation must be a boolean"
      end
    let tagSupport' =
      try
        match obj("tagSupport")?
        | let ts_obj: json.Object val =>
          match ParseTagSupport(ts_obj)
          | let ts: TagSupport =>
            ts
          | let err: String =>
            return err
          end
        else
          return "publishDiagnostics.tagSupport must be a JSON object"
        end
      end
    let versionSupport' =
      match try obj("versionSupport")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "publishDiagnostics.versionSupport must be a boolean"
      end
    let codeDescriptionSupport' =
      match try obj("codeDescriptionSupport")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "publishDiagnostics.codeDescriptionSupport must be a boolean"
      end
    let dataSupport' =
      match try obj("dataSupport")? end
      | let bool: Bool =>
        bool
      | let item: json.Item =>
        return "publishDiagnostics.dataSupport must be a boolean"
      end
    object val is PublishDiagnosticsClientCapabilities
      fun relatedInformation(): (Bool | None) => relatedInformation'
      fun tagSupport(): (TagSupport | None) => tagSupport'
      fun versionSupport(): (Bool | None) => versionSupport'
      fun codeDescriptionSupport(): (Bool | None) => codeDescriptionSupport'
      fun dataSupport(): (Bool | None) => dataSupport'
    end

interface val TagSupport
  fun val valueSet(): Array[DiagnosticTag] val

primitive ParseTagSupport
  fun apply(obj: json.Object val): (TagSupport | String) =>
    let valueSet': Array[DiagnosticTag] val =
      try
        match obj("valueSet")?
        | let vs_seq: json.Sequence =>
          let values: Array[DiagnosticTag] trn = Array[DiagnosticTag]
          for item in vs_seq.values() do
            values.push(
              match item
              | let n: I128 if n == DiagnosticTagUnnecessary() =>
                DiagnosticTagUnnecessary
              | let n: I128 if n == DiagnosticTagDeprecated() =>
                DiagnosticTagDeprecated
              else
                return "tagSupport.valueSet.x must be (1 | 2)"
              end)
          end
          consume values
        else
          return "tagSupport.valueSet must be a JSON sequence"
        end
      else
        return "tagSupport.valueSet must be a JSON sequence"
      end
    object val is TagSupport
      fun val valueSet(): Array[DiagnosticTag] val => valueSet'
    end
