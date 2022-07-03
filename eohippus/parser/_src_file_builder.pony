use "itertools"
use ast = "../ast"
use ".."

class _SrcFileBuilder
  let _trivia: _TriviaBuilder
  let _token: _TokenBuilder
  let _literal: _LiteralBuilder
  let _expression: _ExpressionBuilder

  var _src_file: (NamedRule | None) = None
  var _docstring: (NamedRule | None) = None

  var _using: (NamedRule | None) = None
  var _using_pony: (NamedRule | None) = None
  var _using_ffi: (NamedRule | None) = None

  var _typedef: (NamedRule | None) = None

  new create(trivia: _TriviaBuilder, token: _TokenBuilder,
    literal: _LiteralBuilder, expression: _ExpressionBuilder)
  =>
    _trivia = trivia
    _token = token
    _literal = literal
    _expression = expression

  fun ref errsec(allowed: ReadSeq[NamedRule] val, message: String): RuleNode =>
    let trivia = _trivia.trivia()
    let dol = _trivia.dol()
    let eof = _trivia.eof()

    recover val
      NamedRule("Error_Section",
        Conj(
          [
            Neg(Disj([Disj(allowed); eof]))
            Star(Conj([Neg(Disj([dol; eof])); Single()]), 1)
            Look(Disj([dol; trivia; eof]))
          ],
          {(r, c, b) =>
            (ast.ErrorSection(_Build.info(r), c, message), b)
          }
        ))
    end

  fun ref src_file(): NamedRule =>
    match _src_file
    | let r: NamedRule => r
    else
      let t1 = Variable
      let ds = Variable
      let us = Variable
      let td = Variable
      let t2 = Variable

      let trivia = _trivia.trivia()
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
                  docstring()
                  errsec([docstring(); using(); typedef()],
                    ErrorMsg.src_file_expected_docstring_using_or_typedef())
                ])
              ))

              // zero or more usings
              Bind(us, Star(
                Disj([
                  using()
                  errsec([using(); typedef()],
                    ErrorMsg.src_file_expected_using_or_typedef())
                ])
              ))

              // zero or more type definitions
              Bind(td, Star(
                Disj([
                  typedef()
                  errsec([typedef()], ErrorMsg.src_file_expected_typedef())
                ])
              ))

              // post-trivia
              Bind(t2, trivia)
              eof
            ]),
            this~_src_file_action(t1, ds, us, td, t2))
        end
      _src_file = src_file'
      src_file'
    end

  fun tag _src_file_action(t1: Variable, ds: Variable, us: Variable,
    td: Variable, t2: Variable,
    r: Success, c: ast.NodeSeq[ast.Node], b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let t1': ast.Trivia =
      try
        b(t1)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Trivia")), b)
      end

    let docstring': ast.NodeSeq[ast.Docstring] =
      recover val
        try
          Array[ast.Docstring].>concat(
            Iter[ast.Node](b(ds)?._2.values())
              .filter_map[ast.Docstring](
                {(node: ast.Node): (ast.Docstring | None) =>
                  try node as ast.Docstring end
                }))
        else
          Array[ast.Docstring]
        end
      end

    let us': ast.NodeSeq[ast.Node] =
      try
        b(us)?._2
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Usings")), b)
      end

    let td': ast.NodeSeq[ast.Node] =
      try
        b(td)?._2
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("TypeDefs")), b)
      end

    let t2': ast.Trivia =
      try
        b(t2)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("PostTrivia")), b)
      end

    let m = ast.SrcFile(r.data.locator(), _Build.info(r), c, t1', t2',
      docstring', us', td')
    (m, b)

  fun ref docstring(): NamedRule =>
    match _docstring
    | let r: NamedRule => r
    else
      let trivia = _trivia.trivia()
      let post_trivia = _trivia.post_trivia()
      let literal_string = _literal.string()

      let t1 = Variable
      let s = Variable
      let t2 = Variable
      let docstring' =
        recover val
          NamedRule("DocString",
            Conj([
              Bind(t1, trivia)
              Bind(s, literal_string)
              Bind(t2, post_trivia)
            ]),
            this~_docstring_action(t1, s, t2))
        end
      _docstring = docstring'
      docstring'
    end

  fun tag _docstring_action(t1: Variable, s: Variable, t2: Variable,
    r: Success, c: ast.NodeSeq[ast.Node], b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let t1': ast.Trivia =
      try
        b(t1)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Docstring/Trivia")),
            b)
      end

    let s': ast.LiteralString =
      try
        b(s)?._2(0)? as ast.LiteralString
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Docstring/LiteralString")),
              b)
      end

    let t2': ast.Trivia =
      try
        b(t2)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("Docstring/PostTrivia")), b)
      end

    (ast.Docstring(_Build.info(r), c, t1', t2', s'), b)

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
      let trivia0 = _trivia.trivia(0)
      let trivia1 = _trivia.trivia(1)
      let identifier = _expression.identifier()
      let string = _literal.string()
      let glyph_equals = _token.glyph_equals()
      let kwd_use = _token.kwd_use()
      let kwd_if = _token.kwd_if()
      let kwd_not = _token.kwd_not()

      let t1 = Variable
      let id = Variable
      let pt = Variable
      let fl = Variable
      let df = Variable
      let t2 = Variable

      let using_pony' =
        recover val
          NamedRule("UsingPony",
            Conj([
              Bind(t1, trivia0)
              kwd_use
              trivia1
              Star(
                Conj([
                  Bind(id, identifier)
                  trivia1
                  glyph_equals
                  trivia1
                ]) where min = 0, max = 1)
              Bind(pt, string)
              Star(
                Conj([
                  trivia1
                  kwd_if
                  Star(
                    Conj([
                      trivia1
                      Bind(fl, kwd_not)
                    ]) where min = 0, max = 1)
                  trivia1
                  Bind(df, identifier)
                ]) where min = 0, max = 1)
              Bind(t2, trivia0)
            ]),
            this~_using_pony_action(t1, id, pt, fl, df, t2))
        end
      _using_pony = using_pony'
      using_pony'
    end

  fun tag _using_pony_action(t1: Variable, id: Variable, pt: Variable,
    fl: Variable, df: Variable, t2: Variable,
    r: Success, c: ast.NodeSeq[ast.Node], b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let t1': ast.Trivia =
      try
        b(t1)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("UsingPony/Trivia")),
            b)
      end

    let ident = try b(id)?._2(0)? as ast.Identifier end

    let path =
      try
        b(pt)?._2(0)? as ast.LiteralString
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("UsingPony/LiteralString")), b)
      end

    let flag =
      match try b(fl)?._1 end
      | let _: Success =>
        false
      else
        true
      end

    let def = try b(df)?._2(0)? as ast.Identifier end

    let t2': ast.Trivia =
      try
        b(t2)?._2(0)? as ast.Trivia
      else
        return (ast.ErrorSection(_Build.info(r), c,
          ErrorMsg.internal_ast_node_not_bound("UsingPony/PostTrivia")), b)
      end

    (ast.UsingPony(_Build.info(r), c, t1', t2', ident, path, flag, def), b)

  fun ref typedef(): NamedRule =>
    match _typedef
    | let r: NamedRule => r
    else
      let typedef' =
        recover val
          NamedRule("Typedef",
            Literal("foobarbaz"))
        end
      _typedef = typedef'
      typedef'
    end
