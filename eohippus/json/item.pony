use "collections"
use ".."

primitive Null
  fun string(): String iso^ => "null".clone()

type Item is (Object box | Sequence box | String box | I128 | F64 | Bool | Null)
