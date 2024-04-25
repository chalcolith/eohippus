use json = "../../../json"

interface val ClientInfo
  fun val name(): String
  fun val version(): (String | None)

primitive ParseClientInfo
  fun apply(obj: json.Object): (ClientInfo | String) =>
    let name': String =
      try
        match obj("name")?
        | let str: String box =>
          str.clone()
        else
          return "clientInfo.name must be of type string"
        end
      else
        return "clientInfo must contain 'name'"
      end
    let version': (String | None) =
      try
        match obj("version")?
        | let str: String box =>
          str.clone()
        else
          return "clientInfo.version must be of type string"
        end
      end
    object val is ClientInfo
      fun val name(): String => name'
      fun val version(): (String | None) => version'
    end
