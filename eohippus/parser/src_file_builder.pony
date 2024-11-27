use "itertools"
use ast = "../ast"
use ".."

class SrcFileBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _literal: LiteralBuilder
  let _type_type: TypeBuilder
  let _expression: ExpressionBuilder
  var _typedef: TypedefBuilder

  let src_file: NamedRule = NamedRule("a Pony source file")
  let using: NamedRule = NamedRule("a using declaration" where memoize' = true)
  let using_pony: NamedRule = NamedRule("a Pony package using declaration")
  let using_ffi: NamedRule = NamedRule("an FFI using declaration")

  new create(
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder,
    literal: LiteralBuilder,
    type_type: TypeBuilder,
    expression: ExpressionBuilder,
    typedef: TypedefBuilder)
  =>
    _trivia = trivia
    _token = token
    _keyword = keyword
    _literal = literal
    _type_type = type_type
    _expression = expression
    _typedef = typedef

    _build_src_file()
    _build_using()
    _build_using_pony()
    _build_using_ffi()

  fun ref err_sec(allowed: ReadSeq[NamedRule], message: String): RuleNode =>
    _typedef.error_section(allowed, message)

  fun ref _build_src_file() =>
    let t1 = Variable("t1")
    let ds = Variable("ds")
    let us = Variable("us")
    let td = Variable("td")
    let pt = Variable("pt")

    src_file.set_body(
      Conj(
        [ // pre-trivia
          Bind(t1, Ques(_trivia.trivia))

          // zero or more docstrings
          Bind(
            ds,
            Star(
              Disj(
                [ _typedef.doc_string
                  err_sec(
                    [ _typedef.doc_string; using; _typedef.typedef ],
                    ErrorMsg.src_file_expected_docstring_using_or_typedef())
                ])))

          // zero or more usings
          Bind(
            us,
            Star(
            Disj(
              [ using
                err_sec(
                  [ using; _typedef.typedef ],
                  ErrorMsg.src_file_expected_using_or_typedef())
              ])))

          // zero or more type definitions
          Bind(
            td,
            Star(
              Disj(
                [ _typedef.typedef
                  err_sec(
                    [ _typedef.typedef ], ErrorMsg.src_file_expected_typedef())
                ])))

          //
          Bind(pt, _trivia.eof)
        ]),
        recover this~_src_file_action(t1, ds, us, td, pt) end)

  fun tag _src_file_action(
    t1: Variable,
    ds: Variable,
    us: Variable,
    td: Variable,
    pt: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    ( let t1': ast.NodeSeqWith[ast.Trivia],
      let ds': ast.NodeSeqWith[ast.DocString],
      let us': ast.NodeSeqWith[ast.Using],
      let td': ast.NodeSeqWith[ast.Typedef] )
    =
      recover val
        ( _Build.values_and_errors[ast.Trivia](b, t1, r),
          _Build.values_and_errors[ast.DocString](b, ds, r),
          _Build.values_and_errors[ast.Using](b, us, r),
          _Build.values_and_errors[ast.Typedef](b, td, r) )
      end

    let pt' = _Build.values_with[ast.Trivia](b, pt, r)

    let value = ast.NodeWith[ast.SrcFile](
      _Build.info(d, r), c, ast.SrcFile(d.locator, us', td')
      where
        pre_trivia' = t1',
        doc_strings' = ds',
        post_trivia' = pt')
    (value, b)

  fun ref _build_using() =>
    using.set_body(
      Disj(
        [ using_ffi
          using_pony
        ]))

  fun ref _build_using_pony() =>
    let id = Variable("id")
    let pt = Variable("pt")
    let fl = Variable("fl")
    let df = Variable("df")

    using_pony.set_body(
      Conj(
        [ _keyword(ast.Keywords.kwd_use())
          Ques(
            Conj(
              [ Bind(id, _token.identifier)
                _token(ast.Tokens.equals())
              ]))
          Bind(pt, _literal.string)
          Ques(
            Conj(
              [ _keyword(ast.Keywords.kwd_if())
                Ques(Bind(fl, _keyword(ast.Keywords.kwd_not())))
                Bind(df, _token.identifier)
              ]))
        ]),
        recover this~_using_pony_action(id, pt, fl, df) end)

  fun tag _using_pony_action(
    id: Variable,
    pt: Variable,
    fl: Variable,
    df: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let id' = _Build.value_with_or_none[ast.Identifier](b, id, r)

    let pt' =
      try
        _Build.value_with[ast.LiteralString](b, pt, r)?
      else
        return _Build.bind_error(d, r, c, b, "SrcFile/UsingPony/LiteralString")
      end

    let def_true = try _Build.result(b, fl, r)? end is None
    let df' = _Build.value_with_or_none[ast.Identifier](b, df, r)

    let value = ast.NodeWith[ast.Using](
      _Build.info(d, r), c, ast.UsingPony(id', pt', def_true, df'))
    (value, b)

  fun ref _build_using_ffi() =>
    let at = _token(ast.Tokens.at())
    let comma = _token(ast.Tokens.comma())
    let cparen = _token(ast.Tokens.close_paren())
    let ellipsis = _token(ast.Tokens.ellipsis())
    let equals = _token(ast.Tokens.equals())
    let kwd_if = _keyword(ast.Keywords.kwd_if())
    let kwd_not = _keyword(ast.Keywords.kwd_not())
    let kwd_use = _keyword(ast.Keywords.kwd_use())
    let oparen = _token(ast.Tokens.open_paren())
    let ques = _token(ast.Tokens.ques())

    let use_id = Variable("use_id")
    let use_name = Variable("use_name")
    let use_targs = Variable("use_targs")
    let use_params = Variable("use_params")
    let use_ellipsis = Variable("use_ellipsis")
    let use_partial = Variable("use_partial")
    let use_def_not = Variable("use_def_not")
    let use_define = Variable("use_define")

    using_ffi.set_body(
      Conj(
        [ kwd_use
          Ques(Conj([ Bind(use_id, _token.identifier); equals ]))
          at
          Bind(use_name, Disj([ _token.identifier; _literal.string ]))
          Bind(use_targs, _type_type.args)
          oparen
          Ques(
            Disj(
              [ Bind(use_ellipsis, ellipsis)
                Conj(
                  [ Bind(use_params, _typedef.method_params)
                    Ques(Conj([ comma; Bind(use_ellipsis, ellipsis) ]))
                  ])
              ]))
          cparen
          Ques(Bind(use_partial, ques))
          Ques(
            Conj(
              [ kwd_if
                Ques(Bind(use_def_not, kwd_not))
                Bind(use_define, _token.identifier)
              ]))
        ]),
      recover
        this~_using_ffi_action(
          use_id,
          use_name,
          use_targs,
          use_params,
          use_ellipsis,
          use_partial,
          use_def_not,
          use_define)
      end)

  fun tag _using_ffi_action(
    id: Variable,
    name: Variable,
    targs: Variable,
    params: Variable,
    ellipsis: Variable,
    partial: Variable,
    def_not: Variable,
    define: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let id' = _Build.value_with_or_none[ast.Identifier](b, id, r)
    let name' =
      try
        _Build.value_with[ast.Identifier](b, name, r)?
      else
        try
          _Build.value_with[ast.LiteralString](b, name, r)?
        else
          return _Build.bind_error(d, r, c, b, "SrcFile/UsingFfi/Name")
        end
      end
    let targs' =
      try
        _Build.value_with[ast.TypeArgs](b, targs, r)?
      else
        return _Build.bind_error(d, r, c, b, "SrcFile/UsingFfi/TypeArgs")
      end
    let params' = _Build.value_with_or_none[ast.MethodParams](b, params, r)
    let ellipsis' = b.contains(ellipsis, r)
    let partial' = b.contains(partial, r)
    let def_not' = b.contains(def_not, r)
    let define' = _Build.value_with_or_none[ast.Identifier](b, define, r)

    let value = ast.NodeWith[ast.Using](
      _Build.info(d, r),
      c,
      ast.UsingFFI(
        id',
        name',
        targs',
        params',
        ellipsis',
        partial',
        not def_not',
        define'))
    (value, b)
