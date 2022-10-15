use "itertools"

use ast = "../ast"

class ExpressionBuilder
  let _context: Context
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _type: TypeBuilder

  var _identifier: (NamedRule | None) = None
  var _annotation: (NamedRule | None) = None
  var _prefix_op: (NamedRule | None) = None
  var _seq: (NamedRule | None) = None
  var _atom: (NamedRule | None) = None

  new create(context: Context, trivia: TriviaBuilder, token: TokenBuilder,
    keyword: KeywordBuilder, type_builder: TypeBuilder)
  =>
    _context = context
    _trivia = trivia
    _token = token
    _keyword = keyword
    _type = type_builder

  fun ref identifier(): NamedRule =>
    match _identifier
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()
      let id_chars: String = _Letters.with_underscore() + _Digits() + "'"

      let identifier' =
        recover val
          NamedRule("Identifier",
            _Build.with_post[ast.Trivia](
              recover
                Disj([
                  Conj([
                    Single(ast.Tokens.underscore())
                    Star(Single(id_chars))
                  ])
                  Conj([
                    Single(_Letters())
                    Star(Single(id_chars))
                  ])
                ])
              end,
              trivia,
              {(r, _, b, p) =>
                let str =
                  recover val
                    String.>concat(r.start.values(p.src_info().start()))
                  end
                (ast.Identifier(_Build.info(r), p, str), b)
              }
            ))
        end
      _identifier = identifier'
      identifier'
    end

  fun ref annotation(): NamedRule =>
    match _annotation
    | let r: NamedRule => r
    else
      let bs = _token.backslash()
      let comma = _token.comma()
      let trivia = _trivia.trivia()
      let id = identifier()

      let annotation' =
        recover val
          NamedRule("Annotation",
            _Build.with_post[ast.Trivia](
              recover
                Conj([
                  bs
                  trivia
                  id
                  Star(Conj([ trivia; comma; trivia; id ]))
                  trivia
                  bs
                ])
              end,
              trivia,
              {(r, c, b, p) => (ast.Annotation(_Build.info(r), c, p), b)}
            ))
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
    let trivia = _trivia.trivia()
    let id = identifier()
    let kwd_loc = _keyword.kwd_loc()
    let kwd_this = _keyword.kwd_this()

    // we need to build these in one go since they are mutually recursive
    (let seq', let atom') =
      recover val
        let exp_seq = NamedRule("Expression_Sequence", None)
        let exp_term = NamedRule("Expression_Term", None)

        let exp_if = NamedRule("Expression_If", None)
        let exp_ifdef = NamedRule("Expression_IfDef", None)
        let exp_iftype = NamedRule("Expression_IfType", None)
        let exp_match = NamedRule("Expression_Match", None)
        let exp_while = NamedRule("Expression_While", None)
        let exp_repeat = NamedRule("Expression_Repeat", None)
        let exp_for = NamedRule("Expression_For", None)
        let exp_with = NamedRule("Expression_With", None)
        let exp_try = NamedRule("Expression_Try", None)
        let exp_recover = NamedRule("Expression_Recover", None)
        let exp_consume = NamedRule("Expression_Consume", None)
        let exp_pattern = NamedRule("Expression_Pattern", None)
        let exp_hash = NamedRule("Expression_Hash", None)

        exp_term.set_body(
          Disj([
            exp_if
            exp_ifdef
            exp_iftype
            exp_match
            exp_while
            exp_repeat
            exp_for
            exp_with
            exp_try
            exp_recover
            exp_consume
            exp_pattern
            exp_hash
          ])
        )

        let exp_decl = NamedRule("Expression_Declaration", None)
        let exp_prefix = NamedRule("Expression_Prefix", None)

        exp_pattern.set_body(
          Disj([
            exp_decl
            exp_prefix
          ])
        )

        let exp_postfix = NamedRule("Expression_Postfix", None)

        exp_prefix.set_body(
          Disj([
            _prefix_body(trivia, prefix_op(), exp_prefix)
            exp_postfix
          ]))

        let exp_tuple = NamedRule("Expression_Tuple", None)
        let exp_parens = NamedRule("Expression_Parenthesized", None)
        let exp_array = NamedRule("Expression_Array", None)
        let exp_ffi = NamedRule("Expression_Ffi", None)
        let exp_bare_lambda = NamedRule("Expression_BareLambda", None)
        let exp_lambda = NamedRule("Expression_Lambda", None)
        let exp_object = NamedRule("Expression_Object", None)
        let exp_atom = NamedRule("Expression_Atom", None)

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

  fun ref prefix_op(): NamedRule =>
    match _prefix_op
    | let r: NamedRule => r
    else
      let kwd_not = _keyword.kwd_not()
      let kwd_addressof = _keyword.kwd_addressof()
      let kwd_digestof = _keyword.kwd_digestof()
      let minus = _token.minus()
      let minus_tilde = _token.minus_tilde()

      let prefix_op' =
        recover val
          NamedRule("Expression_Prefix_Op",
            Disj([
              kwd_not
              kwd_addressof
              kwd_digestof
              minus
              minus_tilde
            ]))
        end
      _prefix_op = prefix_op'
      prefix_op'
    end

  fun tag _prefix_body(trivia: NamedRule, op: NamedRule,
    exp_prefix: NamedRule box) : RuleNode ref
  =>
    let po = Variable
    let rhs = Variable

    Conj(
      [
        Bind(po, op)
        trivia
        Bind(rhs, exp_prefix)
      ],
      {(r, c, b) =>
        let op' =
          try
            _Build.value(b, po)? as (ast.Keyword | ast.Token)
          else
            return _Build.bind_error(r, c, b, "Expression/Prefix/Operation")
          end

        let rhs' =
          try
            _Build.value(b, rhs)?
          else
            return _Build.bind_error(r, c, b, "Expression/Prefix/RHS")
          end

        (ast.Operation(_Build.info(r), c, None, op', rhs'), b)
      }
    )
