use json = "../../../../json"

interface val DefinitionClientCapabilities
  fun val dynamicRegistration(): (Bool | None)
  fun val linkSupport(): (Bool | None)

primitive ParseDefinitionClientCapabilities
  fun apply(obj: json.Object val): (DefinitionClientCapabilities | String) =>
    let dynamicRegistration' =
      match try obj("dynamicRegistration")? end
      | let bool: Bool =>
        bool
      | let _: json.Item =>
        return "definition.dynamicRegistration must be a boolean"
      end
    let linkSupport' =
      match try obj("linkSupport")? end
      | let bool: Bool =>
        bool
      | let _: json.Item =>
        return "definition.linkSupport must be a boolean"
      end
    object val is DefinitionClientCapabilities
      fun val dynamicRegistration(): (Bool | None) => dynamicRegistration'
      fun val linkSupport(): (Bool | None) => linkSupport'
    end
