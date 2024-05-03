use "collections"

type Config is Map[String, String]

primitive ConfigKey
  fun tag trim_trailing_whitespace(): String => "trim_trailing_whitespace"
