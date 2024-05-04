use json = "../../../../json"

use ".."

interface val WorkspaceEditClientCapabilities
  fun val documentChanges(): (Bool | None)
  fun val resourceOperations(): (Array[ResourceOperationKind] val | None)
  // fun val failureHandling(): (FailureHandlingKind | None)
  // fun val normalizesLineEndings(): (Bool | None)
  // fun val changeAnnotationSupport():
  //   (ChangeAnnotationSupportClientCapability | None)

primitive ParseWorkspaceEditClientCapabilities
  fun apply(obj: json.Object): (WorkspaceEditClientCapabilities | String) =>
    let documentChanges' =
      try
        match obj("documentChanges")?
        | let b: Bool =>
          b
        else
          return "workspaceEdit.documentChanges must be of type boolean"
        end
      end
    let resourceOperations': (Array[ResourceOperationKind] val | None)  =
      try
        match obj("resourceOperations")?
        | let ro_seq: json.Sequence =>
          let ops: Array[ResourceOperationKind] trn =
            Array[ResourceOperationKind]
          for item in ro_seq.values() do
            match ParseResourceOperationKind(item)
            | let rok: ResourceOperationKind =>
              ops.push(rok)
            | let err: String =>
              return err
            end
          end
          consume ops
        else
          return "workspaceEdit.resourceOperations must be an array"
        end
      end
    object val is WorkspaceEditClientCapabilities
      fun val documentChanges(): (Bool | None) => documentChanges'
      fun val resourceOperations(): (Array[ResourceOperationKind] val | None) =>
        resourceOperations'
    end

interface val ChangeAnnotationSupportClientCapability
  fun val groupsOnLabel(): (Bool | None)

primitive ParseChangeAnnotationSupportClientCapability
  fun apply(obj: json.Object):
    (ChangeAnnotationSupportClientCapability | String)
  =>
    let groupsOnLabel' =
      try
        match obj("groupsOnLabel")?
        | let b: Bool =>
          b
        else
          return "changeAnnotationSupport.groupsOnLabel must be of type boolean"
        end
      end
    object val is ChangeAnnotationSupportClientCapability
      fun val groupsOnLabel(): (Bool | None) => groupsOnLabel'
    end
