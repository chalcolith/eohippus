use json = "../../../../json"

interface val RegularExpressionsClientCapabilities
  fun val engine(): String
  fun val version(): (String | None)

primitive ParseRegularExpressionsClientCapabilities
  fun apply(obj: json.Object val):
    (RegularExpressionsClientCapabilities | String)
  =>
    let engine': String =
      try
        match obj("engine")?
        | let e: String =>
          e.clone()
        else
          return "regularExpressions.engine must be of type string"
        end
      else
        return "RegularExpressionsClientCapabilities must contain 'engine'"
      end
    let version': (String | None) =
      try
        match obj("version")?
        | let v: String =>
          v.clone()
        else
          return "regularExpressions.version must be of type string"
        end
      end
    object val is RegularExpressionsClientCapabilities
      fun val engine(): String => engine'
      fun val version(): (String | None) => version'
    end
