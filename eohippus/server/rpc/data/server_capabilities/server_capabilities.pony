use json = "../../../../json"

use ".."

interface val ServerCapabilities is ResultData
  fun val positionEncoding(): (PositionEncodingKind | None) => None
  fun val textDocumentSync():
    (TextDocumentSyncOptions | TextDocumentSyncKind | None) => None
  fun val notebookDocumentSync():
    ( NotebookDocumentSyncOptions
    | NotebookDocumentSyncRegistrationOptions
    | None) => None
  // fun val completionProvider(): (CompletionProvider | None) => None
  // fun val hoverProvider(): (Bool | HoverOptions | None) => None
  // fun val signatureHelpProvider(): (SignatureHelpOptions | None) => None
  // fun val declarationProvider():
  //   (Bool | DeclarationOptions | DeclarationRegistrationOptions | None) => None
  fun val definitionProvider(): (Bool | DefinitionOptions | None) => None
  // fun val typeDefinitionProvider():
  //   (Bool | TypeDefinitionOptions | TypeDefinitionRegistrationOptions | None)
  // =>
  //   None
  // fun val implementationProvider():
  //   (Bool | ImplementationOptions | ImplementationRegistrationOptions | None)
  // =>
  //   None
  // fun val referencesProvider(): (Bool | ReferenceOptions | None) => None
  // fun val documentHighlightProvider(): (Bool | DocumentHighlightOptions | None)
  // =>
  //   None
  // fun val documentSymbolProvider(): (Bool | DocumentSymbolOptions | None) =>
  //   None
  // fun val codeActionProvider(): (Bool | CodeActionOptions | None) => None
  // fun val codeLensProvider(): (CodeLensOptions | None) => None
  // fun val documentLinkProvider(): (DocumentLinkOptions | None) => None
  // fun val colorProvider():
  //   (Bool | DocumentColorOptions | DocumentColorRegistrationOptions | None)
  // => None
  // fun val documentFormattingProvider():
  //   (Bool | DocumentFormattingOptions | None) => None
  // fun val documentRangeFormattingProvider():
  //   (Bool | DocumentRangeFormattingOptions | None) => None
  // fun val documentOnTypeFormattingProvider():
  //   (DocumentOnTypeFormattingOptions | None) => None
  // fun val renameProvider(): (Bool | RenameOptions | None) => None
  // fun val foldingRangeProvider():
  //   (Bool | FoldingRangeOptions | FoldingRangeRegistrationOptions | None)
  // =>
  //   None
  // fun val executeCommandProvider(): (ExecuteCommandOptions | None) => None
  // fun val selectionRangeProvider():
  //   (Bool | SelectionRangeOptions | SelectionRangeRegistrationOptions | None)
  // =>
  //   None
  // fun val linkedEditingRangeProvider():
  //   ( Bool
  //   | LinkedEditingRangeOptions
  //   | LinkedEditingRangeRegistrationOptions
  //   | None) => None
  // fun val callHierarchyProvder():
  //   (Bool | CallHierarchyOptions | CallHierarchyRegistrationOptions | None)
  // =>
  //   None
  fun val semanticTokensProvider():
    (SemanticTokensOptions | SemanticTokensRegistrationOptions | None) => None
  // fun val monikerProvider():
  //   (Bool | MonikerOptions | MonikerRegistrationOptions | None) => None
  // fun val typeHierarchyProvider():
  //   (Bool | TypeHierarchyOptions | TypeHierarchyRegistrationOptions | None)
  // =>
  //   None
  // fun val inlineValueProvider():
  //   (Bool | InlineValueOptions | InlineValueRegistrationOptions | None) => None
  // fun val inlayHintProvider():
  //   (Bool | InlayHintOptions | InlayHintRegistrationOptions | None) => None
  // fun val diagnosticProvider():
  //   (DiagnosticOptions | DiagnosticRegistrationOptions | None) => None
  // fun val workspaceSymbolProvider(): (Bool | WorkspaceSymbolOptions | None) =>
  //   None
  // fun val workspace(): (WorkspaceServerCapabilities | None) => None
  // fun val experimental(): (json.Item | None)

  fun val get_json(): json.Item =>
    let props = Array[(String, json.Item)]
    match positionEncoding()
    | let pe: PositionEncodingKind =>
      props.push(("positionEncoding", PositionEncodingKindJson(pe)))
    end
    match textDocumentSync()
    | let tdso: TextDocumentSyncOptions =>
      props.push(("textDocumentSync", tdso.get_json()))
    | let tdsk: TextDocumentSyncKind =>
      props.push(("textDocumentSync", TextDocumentSyncKindJson(tdsk)))
    end
    match definitionProvider()
    | let bool: Bool =>
      props.push(("definitionProvider", bool))
    | let def: DefinitionOptions =>
      props.push(("definitionProvider", def.get_json()))
    end
    match notebookDocumentSync()
    | let data: ResultData =>
      props.push(("notebookDocumentSync", data.get_json()))
    end
    json.Object(props)
