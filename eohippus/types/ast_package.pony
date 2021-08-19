use "collections/persistent"

trait AstPackage
  fun name(): String
  fun locator(): String

  fun all_types(): List[AstType]
