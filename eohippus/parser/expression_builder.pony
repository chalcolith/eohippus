use "itertools"

use ast = "../ast"

class ExpressionBuilder
  let _context: Context
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _operator: OperatorBuilder
  let _type: TypeBuilder

  var _identifier: (NamedRule | None) = None
  var _annotation: (NamedRule | None) = None
  var _exp_seq: (NamedRule | None) = None

  new create(
    context: Context,
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder,
    operator: OperatorBuilder,
    type_builder: TypeBuilder)
  =>
    _context = context
    _trivia = trivia
    _token = token
    _keyword = keyword
    _operator = operator
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

  fun ref seq(): NamedRule =>
    match _exp_seq
    | let r: NamedRule => r
    else
      _build_seq()
    end

  fun ref _build_seq(): NamedRule =>
    let trivia = _trivia.trivia()
    let id = identifier()
    let prefix_op = _operator.prefix_op()
    let binary_op = _operator.binary_op()
    let postfix_op = _operator.postfix_op()
    let kwd_loc = _keyword.kwd_loc()
    let kwd_this = _keyword.kwd_this()
    let semicolon = _token.semicolon()
    let equals = _token.equals()
    let kwd_as = _keyword.kwd_as()
    let kwd_return = _keyword.kwd_return()
    let kwd_break = _keyword.kwd_break()
    let kwd_error = _keyword.kwd_error()
    let kwd_continue = _keyword.kwd_continue()
    let kwd_compile_intrinsic = _keyword.kwd_compile_intrinsic()
    let kwd_compile_error = _keyword.kwd_compile_error()
    let type_rule = _type.type_rule()

    // we need to build these in one go since they are mutually recursive
    let exp_seq' =
      recover val
        let exp_seq = NamedRule("Expression_Sequence", None)               // x
        let exp_item = NamedRule("Expression_Item", None)                  // x
        let exp_assignment = NamedRule("Expression_Assignment", None)      // x
        let exp_infix = NamedRule("Expression_Infix", None)                // x
        let exp_jump = NamedRule("Expression_Jump", None)                  // x
        let exp_term = NamedRule("Expression_Term", None)                  // x
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
        let exp_hash = NamedRule("Expression_Hash", None)
        let exp_decl = NamedRule("Expression_Declaration", None)
        let exp_prefix = NamedRule("Expression_Prefix", None)              // x
        let exp_postfix = NamedRule("Expression_Postfix", None)            // x
        let exp_tuple = NamedRule("Expression_Tuple", None)
        let exp_parens = NamedRule("Expression_Parenthesized", None)
        let exp_array = NamedRule("Expression_Array", None)
        let exp_ffi = NamedRule("Expression_Ffi", None)
        let exp_bare_lambda = NamedRule("Expression_BareLambda", None)
        let exp_lambda = NamedRule("Expression_Lambda", None)
        let exp_object = NamedRule("Expression_Object", None)
        let exp_atom = NamedRule("Expression_Atom", None)                  // x
        let type_params = NamedRule("Expression_TypeParams", None)
        let call_params = NamedRule("Expression_CallParams", None)

        let lhs = Variable
        let op = Variable
        let rhs = Variable
        let params = Variable

        // seq <= item (';'? item)*
        exp_seq.set_body(
          Conj([
            exp_item
            Star(
              Conj([
                Star(semicolon, 0, None, 1)
                exp_item
              ]))
          ],
          {(r, c, b) =>
            (ast.Sequence(_Build.info(r), c), b)
          }))

        // item <= assignment / jump
        exp_item.set_body(
          Disj([
            exp_assignment
            exp_jump
          ]))

        // assignment <= (infix '=' assignment) / infix
        exp_assignment.set_body(
          Disj([
            Conj([
              Bind(lhs, exp_infix)
              Bind(op, equals)
              Bind(rhs, exp_assignment)
            ], this~_binop_action(lhs, op, rhs))
            exp_infix
          ]))

        // infix <= (term binary_op infix) / (term 'as' type) / term
        exp_infix.set_body(
          Disj([
            Disj([
              Conj([
                Bind(lhs, exp_term)
                Bind(op, binary_op)
                Bind(rhs, exp_infix)
              ])
              Conj([
                Bind(lhs, exp_term)
                Bind(op, kwd_as)
                Bind(rhs, type_rule)
              ])
            ], this~_binop_action(lhs, op, rhs))
            exp_term
          ]))

        // term <= if / ifdef / iftype / match / while / repeate / for / with /
        //         try / recover / consume / decl / prefix / hash
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
            exp_decl
            exp_prefix
            exp_hash
          ]))

        // prefix <= (prefix_op prefix) / postfix
        exp_prefix.set_body(
          Disj([
            Conj([
              Bind(op, prefix_op)
              Bind(rhs, exp_prefix)
            ], this~_prefix_action(op, rhs))
            exp_postfix
          ]))

        // postfix <= (postfix postfix_op identifier) /
        //            (postfix type_params) /
        //            (postfix call_params) /
        //            atom
        exp_postfix.set_body(
          Disj([
            Conj([
              Bind(lhs, exp_postfix)
              Bind(op, postfix_op)
              Bind(rhs, id)
            ], this~_binop_action(lhs, op, rhs))
            Conj([
              Bind(lhs, exp_postfix)
              Bind(params, type_params)
            ], this~_postfix_type_action(lhs, params))
            Conj([
              Bind(lhs, exp_postfix)
              Bind(params, call_params)
            ], this~_postfix_call_action(lhs, params))
            exp_atom
          ]))

        exp_jump.set_body(
          Disj([
            kwd_return
            kwd_break
            kwd_continue
            kwd_error
            kwd_compile_intrinsic
            kwd_compile_error
          ],
          {(r, c, b) =>
            for child in c.values() do
              match child
              | let kwd: ast.Keyword =>
                return (ast.Jump(_Build.info(r), c, kwd), b)
              end
            end
            _Build.bind_error(r, c, b, "Expression/Jump/Keyword")
          }))

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
          ]))

        exp_seq
      end
    _exp_seq = exp_seq'
    exp_seq'

  fun tag _binop_action(
    lhs: Variable,
    op: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Assignment/LHS")
      end
    let op' =
      try
        _Build.value(b, op)? as (ast.Keyword | ast.Token)
      else
        return _Build.bind_error(r, c, b, "Expression/Assignment/Op")
      end
    let rhs' =
      try
        _Build.value(b, rhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Assignment/RHS")
      end
    (ast.Operation(_Build.info(r), c, lhs', op', rhs'), b)

  fun tag _prefix_action(
    op: Variable,
    rhs: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let op' =
      try
        _Build.value(b, op)? as (ast.Keyword | ast.Token)
      else
        return _Build.bind_error(r, c, b, "Expression/Prefix/Op")
      end
    let rhs' =
      try
        _Build.value(b, rhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Prefix/RHS")
      end
    (ast.Operation(_Build.info(r), c, None, op', rhs'), b)

  fun tag _postfix_type_action(
    lhs: Variable,
    params: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Op")
      end
    let params' =
      try
        _Build.values(b, params)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Params")
      end
    (ast.TypeParams(_Build.info(r), c, lhs', params'), b)

  fun tag _postfix_call_action(
    lhs: Variable,
    params: Variable,
    r: Success,
    c: ast.NodeSeq[ast.Node],
    b: Bindings): ((ast.Node | None), Bindings)
  =>
    let lhs' =
      try
        _Build.value(b, lhs)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Op")
      end
    let params' =
      try
        _Build.values(b, params)?
      else
        return _Build.bind_error(r, c, b, "Expression/Postfix/Params")
      end
    (ast.Call(_Build.info(r), c, lhs', params'), b)
