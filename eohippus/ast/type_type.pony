type TypeType is
  (TypeArrow | TypeAtom | TypeTuple | TypeInfix | TypeNominal | TypeLambda)
  """
    The reason for using `TypeType` and `type_type` is that `type` is a
    reserved word in Pony.
  """
