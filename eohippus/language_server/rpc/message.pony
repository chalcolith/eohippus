use json = "../../json"

interface val RequestMessage
  fun val id(): (I128 | String val)
  fun val method(): String val

interface val ResponseMessage
  fun val id(): (I128 | String val | json.Null)
  fun val result(): (json.Item | None) => None
  fun val err(): (ResponseError | None) => None

interface val ResponseError
  fun val code(): I128
  fun val message(): String val
  fun val data(): (json.Item | None) => None
