use json = "../../../../json"

interface val WorkspaceClientCapabilities
  fun val applyEdit(): (Bool | None)
  fun val workspaceEdit(): (WorkspaceEditClientCapabilities | None)
  // fun val didChangeConfiguration()
  //   : (DidChangeConfigurationClientCapabilities | None)
  // fun val didChangeWatchedFiles()
  //   : (DidChangeWatchedFilesClientCapabilities | None)
  // fun val symbol(): (WorkspaceSymbolClientCapabilities | None)
  // fun val executeCommand(): (ExecuteCommandClientCapabilities | None)
  // fun val workspaceFolders(): (Bool | None)
  // fun val configuration(): (Bool | None)
  // fun val semanticTokens(): (SemanticTokensWorkspaceClientCapabilities | None)
  // fun val codeLens(): (CodeLensWorkspaceClientCapabilities | None)
  // fun val fileOperations(): (FileOperationsWorkspaceClientCapabilities | None)
  // fun val inlineValue(): (InlineValueWorkspaceClientCapabilities | None)
  // fun val inlayHint(): (InlayHintWorkspaceClientCapabilities | None)
  // fun val diagnostics(): (DiagnosticWorkspaceClientCapabilities | None)

primitive ParseWorkspaceClientCapabilities
  fun apply(obj: json.Object): (WorkspaceClientCapabilities | String) =>
    let applyEdit' =
      try
        match obj("applyEdit")?
        | let ae: Bool =>
          ae
        else
          return "workspace.applyEdit must be of type boolean"
        end
      end
    let workspaceEdit' =
      try
        match obj("workspaceEdit")?
        | let we_obj: json.Object =>
          match ParseWorkspaceEditClientCapabilities(we_obj)
          | let we: WorkspaceEditClientCapabilities =>
            we
          | let err: String =>
            return err
          end
        else
          return "workspace.workspaceEdit must be a JSON object"
        end
      end
    // let didChangeConfiguration' =
    //   try
    //     match obj("didChangeConfiguration")?
    //     | let dcc_obj: json.Object =>
    //       match ParseDidChangeConfigurationClientCapabilities(dcc_obj)
    //       | let dcc: DidChangeConfigurationClientCapabilities =>
    //         dcc
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.didChangeConfiguration must be a JSON object"
    //     end
    //   end
    // let didChangeWatchedFiles' =
    //   try
    //     match obj("didChangeWatchedFiles")?
    //     | let dcwf_obj: json.Object =>
    //       match ParseDidChangeWatchedFilesClientCapabilities(dcwf_obj)
    //       | let dcwf: DidChangeWatchedFilesClientCapabilities =>
    //         dcwf
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.didChangeWatchedFiles must be a JSON object"
    //     end
    //   end
    // let symbol' =
    //   try
    //     match obj("symbol")?
    //     | let s_obj: json.Object =>
    //       match ParseWorkspaceSymbolClientCapabilities(s_obj)
    //       | let s: WorkspaceSymbolClientCapabilities =>
    //         s
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.symbol must be a JSON object"
    //     end
    //   end
    // let executeCommand' =
    //   try
    //     match obj("executeCommand")?
    //     | let ec_obj: json.Object =>
    //       match ParseExecuteCommandClientCapabilities(ec_obj)
    //       | let ec: ExecuteCommandClientCapabilities =>
    //         ec
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.executeCommand must be a JSON object"
    //     end
    //   end
    // let workspaceFolders' =
    //   try
    //     match obj("workspaceFolders")?
    //     | let wf: Bool
    //       wf
    //     else
    //       return "worksapce.workspaceFolders must be of type boolean"
    //     end
    //   end
    // let configuration' =
    //   try
    //     match obj("configuration")?
    //     | let c: Bool =>
    //       c
    //     else
    //       return "worksapce.configuration must be of type boolean"
    //     end
    //   end
    // let semanticTokens' =
    //   try
    //     match obj("semanticTokens")?
    //     | let st_obj: json.Object =>
    //       match ParseSemanticTokensWorkspaceClientCapabilities(st_obj)
    //       | let st: SemanticTokensWorkspaceClientCapabilities =>
    //         st
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.semanticTokens must be a JSON object"
    //     end
    //   end
    // let codeLens' =
    //   try
    //     match obj("codeLens")?
    //     | let cl_obj: json.Object =>
    //       match ParseCodeLensWorkspaceClientCapabilities(cl_obj)
    //       | let cl: CodeLensWorkspaceClientCapabilities =>
    //         cl
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.codeLens must be a JSON object"
    //     end
    //   end
    // let fileOperations' =
    //   try
    //     match obj("fileOperations")?
    //     | let fo_obj: json.Object =>
    //       match ParseFileOperationsWorkspaceClientCapabilities =>
    //       | let fo: FileOperationsWorkspaceClientCapabilities =>
    //         fo
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.fileOperations must be a JSON object"
    //     end
    //   end
    // let inlineValue' =
    //   try
    //     match obj("inlineValue")?
    //     | let iv_obj: json.Object =>
    //       match ParseInlineValueWorkspaceClientCapabilities(iv_obj)
    //       | let iv: InlineValueWorkspaceClientCapabilities =>
    //         iv
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.inlineValue must be a JSON object"
    //     end
    //   end
    // let inlayHint' =
    //   try
    //     match obj("inlayHint")?
    //     | let ih_obj: json.Object =>
    //       match ParseInlayHintWorkspaceClientCapabilities(ih_obj)
    //       | let ih: InlayHintWorksapceClientCapabilities =>
    //         ih
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.inlayHint must be a JSON object"
    //     end
    //   end
    // let diagnostics' =
    //   try
    //     match obj("diagnostics")?
    //     | let d_obj: json.Object =>
    //       match ParseDiagnosticWorkspaceClientCapabilities =>
    //       | d: DiagnosticsWorksapceClientCapabilities =>
    //         d
    //       | let err: String =>
    //         return err
    //       end
    //     else
    //       return "workspace.diagnostics must be a JSON object"
    //     end
    //   end
    object val is WorkspaceClientCapabilities
      fun val applyEdit(): (Bool | None) => applyEdit'
      fun val workspaceEdit(): (WorkspaceEditClientCapabilities | None) =>
        workspaceEdit'
      // fun val didChangeConfiguration()
      //   : (DidChangeConfigurationClientCapabilities | None) =>
      //     didChangeConfiguration'
      // fun val didChangeWatchedFiles()
      //   : (DidChangeWatchedFilesClientCapabilities | None) =>
      //     didChangeWatchedFiles'
      // fun val symbol(): (WorkspaceSymbolClientCapabilities | None) => symbol'
      // fun val executeCommand(): (ExecuteCommandClientCapabilities | None) =>
      //   executeCommand'
      // fun val workspaceFolders(): (Bool | None) => workspaceFolders'
      // fun val configuration(): (Bool | None) => configuration'
      // fun val semanticTokens()
      //   : (SemanticTokensWorkspaceClientCapabilities | None) => semanticTokens'
      // fun val codeLens(): (CodeLensWorkspaceClientCapabilities | None) =>
      //   codeLens'
      // fun val fileOperations()
      //   : (FileOperationsWorkspaceClientCapabilities | None) => fileOperations'
      // fun val inlineValue(): (InlineValueWorkspaceClientCapabilities | None) =>
      //   inlineValue'
      // fun val inlayHint(): (InlayHintWorkspaceClientCapabilities | None) =>
      //   inlayHint'
      // fun val diagnostics(): (DiagnosticWorkspaceClientCapabilities | None) =>
      //   diagnostics'
    end
