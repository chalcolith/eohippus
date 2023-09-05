use "itertools"
use ast = "../ast"
use ".."

class SrcFileBuilder
  let _trivia: TriviaBuilder
  let _token: TokenBuilder
  let _keyword: KeywordBuilder
  let _literal: LiteralBuilder
  let _expression: ExpressionBuilder
  var _member: MemberBuilder
  var _typedef: TypedefBuilder

  var _src_file: (NamedRule | None) = None

  var _using: (NamedRule | None) = None
  var _using_pony: (NamedRule | None) = None
  var _using_ffi: (NamedRule | None) = None

  new create(trivia: TriviaBuilder, token: TokenBuilder,
    keyword: KeywordBuilder, literal: LiteralBuilder,
    expression: ExpressionBuilder, member: MemberBuilder,
    typedef: TypedefBuilder)
  =>
    _trivia = trivia
    _token = token
    _keyword = keyword
    _literal = literal
    _expression = expression
    _member = member
    _typedef = typedef

  fun ref err_sec(allowed: ReadSeq[NamedRule] val, message: String): RuleNode =>
    _member.error_section(allowed, message)

  fun ref src_file(): NamedRule =>
    match _src_file
    | let r: NamedRule => r
    else
      let t1 = Variable("t1")
      let ds = Variable("ds")
      let us = Variable("us")
      let td = Variable("td")

      let trivia = _trivia.trivia()
      let doc_string = _member.doc_string()
      let typedef = _typedef.typedef()
      let eol = _trivia.eol()
      let eof = _trivia.eof()

      let src_file' =
        recover val
          NamedRule("SrcFile",
            Conj([
              // pre-trivia
              Bind(t1, Ques(trivia))

              // zero or more docstrings
              Bind(ds, Star(
                Disj([
                  doc_string
                  err_sec([doc_string; using(); typedef],
                    ErrorMsg.src_file_expected_docstring_using_or_typedef())
                ])
              ))

              // zero or more usings
              Bind(us, Star(
                Disj([
                  using()
                  err_sec([using(); typedef],
                    ErrorMsg.src_file_expected_using_or_typedef())
                ])
              ))

              // zero or more type definitions
              Bind(td, Star(
                Disj([
                  typedef
                  err_sec([typedef],
                    ErrorMsg.src_file_expected_typedef())
                ])
              ))

              //
              eof
            ]),
            this~_src_file_action(t1, ds, us, td))
        end
      _src_file = src_file'
      src_file'
    end

  fun tag _src_file_action(
    t1: Variable,
    ds: Variable,
    us: Variable,
    td: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    ( let es': ast.NodeSeqWith[ast.ErrorSection],
      let t1': ast.NodeSeqWith[ast.Trivia],
      let ds': ast.NodeSeqWith[ast.DocString],
      let us': ast.NodeSeqWith[ast.Using],
      let td': ast.NodeSeqWith[ast.TypeDef] )
    =
      recover val
        let errs = Array[ast.NodeWith[ast.ErrorSection]]
        ( errs,
          _Build.values_and_errors[ast.Trivia](b, t1, r, errs),
          _Build.values_and_errors[ast.DocString](b, ds, r, errs),
          _Build.values_and_errors[ast.Using](b, us, r, errs),
          _Build.values_and_errors[ast.TypeDef](b, td, r, errs) )
      end

    let value = ast.NodeWith[ast.SrcFile](
      _Build.info(r), c, ast.SrcFile(r.data.locator, us', td')
      where pre_trivia' = t1', doc_strings' = ds', error_sections' = es')
    (value, b)

  fun ref using(): NamedRule =>
    match _using
    | let r: NamedRule => r
    else
      let using' =
        recover val
          NamedRule("Using",
            Disj([
              using_pony()
            ]))
        end
      _using = using'
      using'
    end

  fun ref using_pony(): NamedRule =>
    match _using_pony
    | let r: NamedRule => r
    else
      let identifier = _token.identifier()
      let string = _literal.string()
      let equals = _token(ast.Tokens.equals())
      let kwd_use = _keyword(ast.Keywords.kwd_use())
      let kwd_if = _keyword(ast.Keywords.kwd_if())
      let kwd_not = _keyword(ast.Keywords.kwd_not())

      let id = Variable("id")
      let pt = Variable("pt")
      let fl = Variable("fl")
      let df = Variable("df")

      let using_pony' =
        recover val
          NamedRule("UsingPony",
            Conj([
              kwd_use
              Ques(
                Conj([
                  Bind(id, identifier)
                  equals
                ]))
              Bind(pt, string)
              Ques(
                Conj([
                  kwd_if
                  Ques(
                    Conj([
                      Bind(fl, kwd_not)
                    ]))
                  Bind(df, identifier)
                ]))
            ]),
            this~_using_pony_action(id, pt, fl, df))
        end
      _using_pony = using_pony'
      using_pony'
    end

  fun tag _using_pony_action(
    id: Variable,
    pt: Variable,
    fl: Variable,
    df: Variable,
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
        return _Build.bind_error(r, c, b, "UsingPony/LiteralString")
      end

    let def_true = try _Build.result(b, fl, r)? end is None
    let df' = _Build.value_with_or_none[ast.Identifier](b, df, r)

    let value = ast.NodeWith[ast.Using](
      _Build.info(r), c, ast.UsingPony(id', pt', def_true, df'))
    (value, b)
