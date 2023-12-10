use "itertools"
use ast = "../ast"
use ".."

class SrcFileBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _literal: LiteralBuilder
  let _expression: ExpressionBuilder
  var _typedef: TypedefBuilder

  let src_file: NamedRule = NamedRule("a Pony source file")
  let using: NamedRule = NamedRule("a using declaration")
  let using_pony: NamedRule = NamedRule("a Pony package using declaration")
  let using_ffi: NamedRule = NamedRule("an FFI using declaration")

  new create(
    trivia: TriviaBuilder,
    token: TokenBuilder,
    keyword: KeywordBuilder,
    literal: LiteralBuilder,
    expression: ExpressionBuilder,
    typedef: TypedefBuilder)
  =>
    _trivia = trivia
    _token = token
    _keyword = keyword
    _literal = literal
    _expression = expression
    _typedef = typedef

    _build_src_file()
    _build_using()
    _build_using_pony()
    // TODO: _build_using_ffi()

  fun ref err_sec(allowed: ReadSeq[NamedRule], message: String): RuleNode =>
    _typedef.error_section(allowed, message)

  fun ref _build_src_file() =>
    let t1 = Variable("t1")
    let ds = Variable("ds")
    let us = Variable("us")
    let td = Variable("td")

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
          _trivia.eof
        ]),
        recover this~_src_file_action(t1, ds, us, td) end)

  fun tag _src_file_action(
    t1: Variable,
    ds: Variable,
    us: Variable,
    td: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    ( let es': ast.NodeSeqWith[ast.ErrorSection],
      let t1': ast.NodeSeqWith[ast.Trivia],
      let ds': ast.NodeSeqWith[ast.DocString],
      let us': ast.NodeSeqWith[ast.Using],
      let td': ast.NodeSeqWith[ast.Typedef] )
    =
      recover val
        let errs = Array[ast.NodeWith[ast.ErrorSection]]
        ( errs,
          _Build.values_and_errors[ast.Trivia](b, t1, r, errs),
          _Build.values_and_errors[ast.DocString](b, ds, r, errs),
          _Build.values_and_errors[ast.Using](b, us, r, errs),
          _Build.values_and_errors[ast.Typedef](b, td, r, errs) )
      end

    let value = ast.NodeWith[ast.SrcFile](
      _Build.info(d, r), c, ast.SrcFile(d.locator, us', td')
      where pre_trivia' = t1', doc_strings' = ds', error_sections' = es')
    (value, b)

  fun ref _build_using() =>
    using.set_body(
      Disj(
        [ using_pony
          // using_ffi
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
        _Build.value_with[ast.Literal](b, pt, r)?
      else
        return _Build.bind_error(d, r, c, b, "UsingPony/LiteralString")
      end

    let def_true = try _Build.result(b, fl, r)? end is None
    let df' = _Build.value_with_or_none[ast.Identifier](b, df, r)

    let value = ast.NodeWith[ast.Using](
      _Build.info(d, r), c, ast.UsingPony(id', pt', def_true, df'))
    (value, b)
