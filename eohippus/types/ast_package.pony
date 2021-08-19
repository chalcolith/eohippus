use "collections/persistent"

trait AstPackage[CH]
  fun name(): String
  fun locator(): String

  fun all_types(): List[AstType[CH]]
