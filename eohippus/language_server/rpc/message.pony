use json = "../../json"

interface val Message
  fun val jsonrpc(): String => "2.0"

interface val RequestMessage is Message
  fun val id(): (I128 | String val)
  fun val method(): String val

interface val ResponseMessage is Message
  fun val id(): (I128 | String val | json.Null)
  fun val result(): (json.Item | None) => None
  fun val err(): (ResponseError | None) => None

interface val ResponseError
  fun val code(): I128
  fun val message(): String val
  fun val data(): (json.Item | None) => None
