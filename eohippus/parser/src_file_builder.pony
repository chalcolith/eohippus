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

  fun ref errsec(allowed: ReadSeq[NamedRule] val, message: String): RuleNode =>
    _member.errsec(allowed, message)

  fun ref src_file(): NamedRule =>
    match _src_file
    | let r: NamedRule => r
    else
      let t1 = Variable("t1")
      let ds = Variable("ds")
      let us = Variable("us")
      let td = Variable("td")

      let trivia = _trivia.trivia()
      let docstring = _member.docstring()
      let typedef = _typedef.typedef()
      let eol = _trivia.eol()
      let eof = _trivia.eof()

      let src_file' =
        recover val
          NamedRule("SrcFile",
            Conj([
              // pre-trivia
              Bind(t1, trivia)

              // zero or more docstrings
              Bind(ds, Star(
                Disj([
                  docstring
                  errsec([docstring; using(); typedef],
                    ErrorMsg.src_file_expected_docstring_using_or_typedef())
                ])
              ))

              // zero or more usings
              Bind(us, Star(
                Disj([
                  using()
                  errsec([using(); typedef],
                    ErrorMsg.src_file_expected_using_or_typedef())
                ])
              ))

              // zero or more type definitions
              Bind(td, Star(
                Disj([
                  typedef
                  errsec([typedef],
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

  fun tag _src_file_action(t1: Variable, ds: Variable, us: Variable,
    td: Variable, r: Success, c: ast.NodeSeq[ast.Node], b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let t1': ast.Trivia =
      try
        _Build.value(b, t1)? as ast.Trivia
      else
        return _Build.bind_error(r, c, b, "Trivia")
      end

    let docstring': ast.NodeSeq[ast.Docstring] = _Build.docstrings(b, ds)

    let us': ast.NodeSeq[ast.Node] =
      try
        _Build.values(b, us)?
      else
        return _Build.bind_error(r, c, b, "Usings")
      end

    let td': ast.NodeSeq[ast.Node] =
      try
        _Build.values(b, td)?
      else
        return _Build.bind_error(r, c, b, "Typedefs")
      end

    let m = ast.SrcFile(_Build.info(r), c, t1', docstring', us', td')
    (m, b)

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
      let identifier = _expression.identifier()
      let string = _literal.string()
      let equals = _token.equals()
      let kwd_use = _keyword.kwd_use()
      let kwd_if = _keyword.kwd_if()
      let kwd_not = _keyword.kwd_not()

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

  fun tag _using_pony_action(id: Variable, pt: Variable, fl: Variable,
    df: Variable, r: Success, c: ast.NodeSeq[ast.Node], b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let ident = try _Build.value(b, id)? as ast.Identifier end

    let path =
      try
        _Build.value(b, pt)? as ast.LiteralString
      else
        return _Build.bind_error(r, c, b, "UsingPony/LiteralString")
      end

    let flag =
      match try b(fl)?._1 end
      | let _: Success =>
        false
      else
        true
      end

    let def = try _Build.value(b, df)? as ast.Identifier end

    (ast.UsingPony(_Build.info(r), c, ident, path, flag, def), b)
