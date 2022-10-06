use ast = "../ast"

class ExpressionBuilder
  let _context: Context
  let _trivia: TriviaBuilder

  var _identifier: (NamedRule | None) = None
  var _annotation: (NamedRule | None) = None

  new create(context: Context, trivia: TriviaBuilder) =>
    _context = context
    _trivia = trivia

  fun ref identifier(): NamedRule =>
    match _identifier
    | let r: NamedRule => r
    else
      let identifier' =
        recover val
          NamedRule("Identifier",
            Disj([
              Conj([
                Single("_")
                Star(Single(_Letters() + _Digits() + "_'"))
              ])
              Conj([
                Single(_Letters())
                Star(Single(_Letters() + _Digits() + "_'"))
              ])
            ]),
            {(r, _, b) => (ast.Identifier(_Build.info(r)), b) }
          )
        end
      _identifier = identifier'
      identifier'
    end

  fun ref annotation(): NamedRule =>
    match _annotation
    | let r: NamedRule => r
    else
      let ws = _trivia.trivia()
      let id = identifier()

      let annotation' =
        recover val
          NamedRule("Annotation",
            Conj([
              Single("\\")
              ws
              id
              ws
              Star(Conj([ Single(","); ws; id ]))
              ws
              Single("\\")
            ])
          )
        end
      _annotation = annotation'
      annotation'
    end
