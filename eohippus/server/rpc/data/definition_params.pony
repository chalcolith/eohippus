use json = "../../../json"

interface val DefinitionParams is
  (TextDocumentPositionParams & WorkDoneProgressParams & PartialResultParams)

primitive ParseDefinitionParams
  fun apply(obj: json.Object val): (DefinitionParams | String) =>
    let textDocument' =
      match try obj("textDocument")? end
      | let td_obj: json.Object val =>
        match ParseTextDocumentIdentifier(td_obj)
        | let tdi: TextDocumentIdentifier =>
          tdi
        | let err: String =>
          return err
        end
      else
        return "DefinitionParams.textDocument must be a JSON object"
      end
    let position' =
      match try obj("position")? end
      | let pos_obj: json.Object val =>
        match ParsePosition(pos_obj)
        | let pos: Position =>
          pos
        | let err: String =>
          return err
        end
      else
        return "DefinitionParams.position must be a JSON object"
      end
    let workDoneToken' =
      match try obj("workDoneToken")? end
      | let n: I128 =>
        n
      | let s: String val =>
        s
      end
    let partialResultToken' =
      match try obj("partialResultToken")? end
      | let n: I128 =>
        n
      | let s: String val =>
        s
      end
    object val is DefinitionParams
      fun val textDocument(): TextDocumentIdentifier => textDocument'
      fun val position(): Position => position'
      fun val workDoneToken(): (ProgressToken | None) => workDoneToken'
      fun val partialResultToken(): (ProgressToken | None) =>
        partialResultToken'
    end
