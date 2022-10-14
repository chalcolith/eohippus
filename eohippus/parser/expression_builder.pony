use "itertools"

use ast = "../ast"

class ExpressionBuilder
  let _context: Context
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder

  var _identifier: (NamedRule | None) = None
  var _annotation: (NamedRule | None) = None
  var _seq: (NamedRule | None) = None
  var _atom: (NamedRule | None) = None

  new create(context: Context, trivia: TriviaBuilder, token: TokenBuilder,
    keyword: KeywordBuilder)
  =>
    _context = context
    _trivia = trivia
    _token = token
    _keyword = keyword

  fun ref identifier(): NamedRule =>
    match _identifier
    | let r: NamedRule => r
    else
      let id_chars: String = _Letters.with_underscore() + _Digits() + "'"

      let identifier' =
        recover val
          NamedRule("Identifier",
            Disj([
              Conj([
                Single(ast.Tokens.underscore())
                Star(Single(id_chars))
              ])
              Conj([
                Single(_Letters())
                Star(Single(id_chars))
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
      let bs = _token.backslash()
      let co = _token.comma()
      let ws = _trivia.trivia()
      let id = identifier()

      let annotation' =
        recover val
          NamedRule("Annotation",
            Conj([
              bs
              ws
              id
              Star(Conj([ ws; co; ws; id ]))
              ws
              bs
            ]),
            {(r, c, b) => (ast.Annotation(_Build.info(r), c), b)}
          )
        end
      _annotation = annotation'
      annotation'
    end

  fun ref atom(): NamedRule =>
    match _atom
    | let r: NamedRule => r
    else
      (_, let atom') = _build_expressions()
      atom'
    end

  fun ref _build_expressions(): (NamedRule, NamedRule) =>
    let id = identifier()
    let kwd_loc = _keyword.kwd_loc()
    let kwd_this = _keyword.kwd_this()

    // we need to build these in one go since they are mutually recursive
    (let seq', let atom') =
      recover val
        let exp_seq = NamedRule("ExpressionSequence", None)
        let exp_tuple = NamedRule("ExpressionTuple", None)
        let exp_parens = NamedRule("ExpressionParenthesized", None)
        let exp_array = NamedRule("ExpressionArray", None)
        let exp_ffi = NamedRule("ExpressionFfi", None)
        let exp_bare_lambda = NamedRule("ExpressionBareLambda", None)
        let exp_lambda = NamedRule("ExpressionLambda", None)
        let exp_object = NamedRule("ExpressionObject", None)
        let exp_atom = NamedRule("ExpressionAtom", None)

        exp_atom.set_body(
          Disj([
            exp_tuple
            exp_parens
            exp_array
            exp_ffi
            exp_bare_lambda
            exp_lambda
            exp_object
            kwd_loc
            kwd_this
            id
          ])
        )

        (exp_seq, exp_atom)
      end
    _seq = seq'
    _atom = atom'

    (seq', atom')
