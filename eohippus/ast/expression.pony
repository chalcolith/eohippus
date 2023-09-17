type Expression is
  ( ExpSequence
  | ExpOperation
  | ExpJump
  | ExpIf
  | ExpGeneric
  | ExpCall
  | ExpAtom
  | ExpHash
  | ExpTuple
  | ExpRecover
  | ExpTry
  | ExpArray
  | ExpConsume
  | ExpWhile
  | ExpRepeat
  | ExpFor
  | ExpMatch
  | ExpDecl
  | ExpWith
  | ExpFfi
  | ExpLambda )
