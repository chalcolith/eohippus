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
