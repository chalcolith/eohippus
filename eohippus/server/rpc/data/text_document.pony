use json = "../../../json"

interface val DidOpenTextDocumentParams
  fun val textDocument(): TextDocumentItem

primitive ParseDidOpenTextDocumentParams
  fun apply(obj: json.Object val): (DidOpenTextDocumentParams | String) =>
    let textDocument' =
      match try obj("textDocument")? end
      | let text_document: json.Object val =>
        match ParseTextDocumentItem(text_document)
        | let tdi: TextDocumentItem =>
          tdi
        | let err: String =>
          return err
        end
      else
        return "DidOpenTextDocumentParams must have a 'textDocument' property"
      end
    object val is DidOpenTextDocumentParams
      fun val textDocument(): TextDocumentItem => textDocument'
    end

interface val TextDocumentItem
  fun val uri(): DocumentUri
  fun val languageId(): String
  fun val version(): I128
  fun val text(): String

primitive ParseTextDocumentItem
  fun apply(obj: json.Object val): (TextDocumentItem | String) =>
    let uri' =
      match try obj("uri")? end
      | let str: String =>
        str
      else
        return "textDocumentItem.uri must be a string"
      end
    let languageId' =
      match try obj("languageId")? end
      | let str: String =>
        str
      else
        return "textDocumentItem.languageId must be a string"
      end
    let version' =
      match try obj("version")? end
      | let int: I128 =>
        int
      else
        return "textDocumentItem.version must be a string"
      end
    let text' =
      match try obj("text")? end
      | let str: String =>
        str
      else
        return "textDocumentItem.text must be a string"
      end
    object val is TextDocumentItem
      fun val uri(): DocumentUri => uri'
      fun val languageId(): String => languageId'
      fun val version(): I128 => version'
      fun val text(): String => text'
    end

interface val DidCloseTextDocumentParams
  fun val textDocument(): TextDocumentIdentifier

primitive ParseDidCloseTextDocumentParams
  fun apply(obj: json.Object val): (DidCloseTextDocumentParams | String) =>
    let textDocument' =
      match try obj("textDocument")? end
      | let text_document: json.Object val =>
        match ParseTextDocumentIdentifier(text_document)
        | let tdi: TextDocumentIdentifier =>
          tdi
        | let err: String =>
          return err
        end
      else
        return "textDocument must be a TextDocumentIdentifier"
      end
    object val is DidCloseTextDocumentParams
      fun val textDocument(): TextDocumentIdentifier => textDocument'
    end

interface val TextDocumentIdentifier
  fun val uri(): DocumentUri

primitive ParseTextDocumentIdentifier
  fun apply(obj: json.Object val): (TextDocumentIdentifier | String) =>
    let uri' =
      match try obj("uri")? end
      | let str: String =>
        str
      else
        return "textDocument.uri must be a string"
      end
    object val is TextDocumentIdentifier
      fun val uri(): DocumentUri => uri'
    end

interface val DidChangeTextDocumentParams
  fun val textDocument(): VersionedTextDocumentIdentifier
  fun val contentChanges(): Array[TextDocumentContentChangeEvent] val

primitive ParseDidChangeTextDocumentParams
  fun apply(obj: json.Object val): (DidChangeTextDocumentParams | String) =>
    let textDocument' =
      match try obj("textDocument")? end
      | let text_document: json.Object val =>
        match ParseVersionedTextDocumentIdentifier(text_document)
        | let vtdi: VersionedTextDocumentIdentifier =>
          vtdi
        | let err: String =>
          return err
        end
      else
        return "textDocument must be an object"
      end
    let contentChanges: Array[TextDocumentContentChangeEvent] trn = []
    match try obj("contentChanges")? end
    | let changes_seq: json.Sequence val =>
      for change_item in changes_seq.values() do
        match change_item
        | let change_obj: json.Object val =>
          match ParseTextDocumentContentChangeEvent(change_obj)
          | let tdce: TextDocumentContentChangeEvent =>
            contentChanges.push(tdce)
          | let err: String =>
            return err
          end
        else
          return "contentChanges must be a sequence of object"
        end
      end
    else
      return "contentChanges must be a sequence"
    end
    let contentChanges': Array[TextDocumentContentChangeEvent] val =
      consume contentChanges
    object val is DidChangeTextDocumentParams
      fun val textDocument(): VersionedTextDocumentIdentifier => textDocument'
      fun val contentChanges(): Array[TextDocumentContentChangeEvent] val =>
        contentChanges'
    end

interface val VersionedTextDocumentIdentifier is TextDocumentIdentifier
  fun val version(): I128

primitive ParseVersionedTextDocumentIdentifier
  fun apply(obj: json.Object val): (VersionedTextDocumentIdentifier | String) =>
    let uri' =
      match try obj("uri")? end
      | let str: String =>
        str
      else
        return "textDocument.uri must be a DocumentUri"
      end
    let version' =
      match try obj("version")? end
      | let int: I128 =>
        int
      else
        return "textDocument.version must be an integer"
      end
    object val is VersionedTextDocumentIdentifier
      fun val uri(): DocumentUri => uri'
      fun val version(): I128 => version'
    end

interface val TextDocumentContentChangeEvent
  fun val range(): (Range | None)
  fun val rangeLength(): (I128 | None)
  fun val text(): String

primitive ParseTextDocumentContentChangeEvent
  fun apply(obj: json.Object val): (TextDocumentContentChangeEvent | String) =>
    let range' =
      match try obj("range")? end
      | let range_obj: json.Object val =>
        match ParseRange(range_obj)
        | let r: Range =>
          r
        | let err: String =>
          return err
        end
      end
    let rangeLength' =
      match try obj("rangeLength")? end
      | let int: I128 =>
        int
      end
    let text' =
      match try obj("text")? end
      | let str: String =>
        str
      else
        return "contentChange.text must be a string"
      end
    object val is TextDocumentContentChangeEvent
      fun val range(): (Range | None) => range'
      fun val rangeLength(): (I128 | None) => rangeLength'
      fun val text(): String => text'
    end

interface val TextDocumentPositionParams is RequestParams
  fun val textDocument(): TextDocumentIdentifier
  fun val position(): Position
