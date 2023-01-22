use "collections"

use ast = "../ast"
use ".."

class KeywordBuilder
  let _context: Context
  let _trivia: TriviaBuilder

  let _keywords: Map[String, NamedRule] val
  var _kwd: (NamedRule | None) = None
  var _cap: (NamedRule | None) = None

  new create(context: Context, trivia: TriviaBuilder) =>
    _context = context
    _trivia = trivia

    let t = _trivia.trivia()
    _keywords =
      recover val
        let k = Map[String, NamedRule]
        _add_rule("Keyword_Addressof", ast.Keywords.kwd_addressof(), t, k)
        _add_rule("Keyword_As", ast.Keywords.kwd_as(), t, k)
        _add_rule("Keyword_Break", ast.Keywords.kwd_break(), t, k)
        _add_rule("Keyword_CompileError", ast.Keywords.kwd_compile_error(), t, k)
        _add_rule("Keyword_CompileIntrinsic", ast.Keywords.kwd_compile_intrinsic(), t, k)
        _add_rule("Keyword_Continue", ast.Keywords.kwd_continue(), t, k)
        _add_rule("Keyword_Digestof", ast.Keywords.kwd_digestof(), t, k)
        _add_rule("Keyword_Else", ast.Keywords.kwd_else(), t, k)
        _add_rule("Keyword_Elseif", ast.Keywords.kwd_elseif(), t, k)
        _add_rule("Keyword_End", ast.Keywords.kwd_end(), t, k)
        _add_rule("Keyword_Error", ast.Keywords.kwd_error(), t, k)
        _add_rule("Keyword_If", ast.Keywords.kwd_if(), t, k)
        _add_rule("Keyword_Ifdef", ast.Keywords.kwd_ifdef(), t, k)
        _add_rule("Keyword_Iftype", ast.Keywords.kwd_iftype(), t, k)
        _add_rule("Keyword_Loc", ast.Keywords.kwd_loc(), t, k)
        _add_rule("Keyword_Not", ast.Keywords.kwd_not(), t, k)
        _add_rule("Keyword_Primitive", ast.Keywords.kwd_primitive(), t, k)
        _add_rule("Keyword_Return", ast.Keywords.kwd_return(), t, k)
        _add_rule("Keyword_Then", ast.Keywords.kwd_then(), t, k)
        _add_rule("Keyword_This", ast.Keywords.kwd_this(), t, k)
        _add_rule("Keyword_Use", ast.Keywords.kwd_use(), t, k)
        k
      end

  fun tag _add_rule(
    name: String,
    str: String,
    t: NamedRule,
    m: Map[String, NamedRule])
  =>
    let rule =
      recover val
        NamedRule(name,
          _Build.with_post[ast.Trivia](
            recover
              Conj([
                Literal(str)
                Neg(Single(_Letters.with_underscore()))
              ])
            end,
            t,
            {(r, _, b, p) => (ast.Keyword(_Build.info(r), p, str), b)}
          ))
      end
    m.insert(str, rule)

  fun apply(str: String): NamedRule =>
    try
      _keywords(str)?
    else
      let msg =
        recover val "INVALID KEYWORD '" + StringUtil.escape(str) + "'" end
      recover val
        NamedRule(msg, Error(msg))
      end
    end

  fun ref kwd(): NamedRule =>
    match _kwd
    | let r: NamedRule => r
    else
      let kwd' =
        recover val
          NamedRule("Keyword",
            Disj(Array[NamedRule].>concat(_keywords.values())))
        end
      _kwd = kwd'
      kwd'
    end

  fun ref cap(): NamedRule =>
    match _cap
    | let r: NamedRule => r
    else
      let kwd_iso = this(ast.Keywords.kwd_iso())
      let kwd_trn = this(ast.Keywords.kwd_trn())
      let kwd_ref = this(ast.Keywords.kwd_ref())
      let kwd_val = this(ast.Keywords.kwd_val())
      let kwd_box = this(ast.Keywords.kwd_box())
      let kwd_tag = this(ast.Keywords.kwd_tag())

      let cap' =
        recover val
          NamedRule("Keyword_Cap",
            Disj([
              kwd_iso
              kwd_trn
              kwd_ref
              kwd_val
              kwd_box
              kwd_tag
            ]))
        end
      _cap = cap'
      cap'
    end
