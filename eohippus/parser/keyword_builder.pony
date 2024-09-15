use "collections"

use ast = "../ast"
use ".."

class KeywordBuilder
  let _kwd_strings: Array[String] val

  let _context: Context
  let _trivia: TriviaBuilder

  let _keywords: Map[String, NamedRule]
  let kwd: NamedRule = NamedRule("a keyword")
  let not_kwd: NamedRule = NamedRule("something other than a keyword")
  let cap: NamedRule = NamedRule("a reference capability")
  let gencap: NamedRule = NamedRule("a generic capability")

  new create(context: Context, trivia: TriviaBuilder) =>
    _context = context
    _trivia = trivia

    _kwd_strings = [
      ast.Keywords.kwd_actor()
      ast.Keywords.kwd_addressof()
      ast.Keywords.kwd_and()
      ast.Keywords.kwd_as()
      ast.Keywords.kwd_be()
      ast.Keywords.kwd_box()
      ast.Keywords.kwd_break()
      ast.Keywords.kwd_class()
      ast.Keywords.kwd_compile_error()
      ast.Keywords.kwd_compile_intrinsic()
      ast.Keywords.kwd_consume()
      ast.Keywords.kwd_continue()
      ast.Keywords.kwd_digestof()
      ast.Keywords.kwd_do()
      ast.Keywords.kwd_elseif()
      ast.Keywords.kwd_else()
      ast.Keywords.kwd_embed()
      ast.Keywords.kwd_end()
      ast.Keywords.kwd_error()
      ast.Keywords.kwd_false()
      ast.Keywords.kwd_for()
      ast.Keywords.kwd_fun()
      ast.Keywords.kwd_hash_alias()
      ast.Keywords.kwd_hash_any()
      ast.Keywords.kwd_hash_read()
      ast.Keywords.kwd_hash_send()
      ast.Keywords.kwd_hash_share()
      ast.Keywords.kwd_iftype()
      ast.Keywords.kwd_ifdef()
      ast.Keywords.kwd_if()
      ast.Keywords.kwd_interface()
      ast.Keywords.kwd_in()
      ast.Keywords.kwd_iso()
      ast.Keywords.kwd_is()
      ast.Keywords.kwd_let()
      ast.Keywords.kwd_loc()
      ast.Keywords.kwd_match()
      ast.Keywords.kwd_new()
      ast.Keywords.kwd_not()
      ast.Keywords.kwd_object()
      ast.Keywords.kwd_or()
      ast.Keywords.kwd_primitive()
      ast.Keywords.kwd_ref()
      ast.Keywords.kwd_recover()
      ast.Keywords.kwd_repeat()
      ast.Keywords.kwd_return()
      ast.Keywords.kwd_struct()
      ast.Keywords.kwd_tag()
      ast.Keywords.kwd_then()
      ast.Keywords.kwd_this()
      ast.Keywords.kwd_trait()
      ast.Keywords.kwd_trn()
      ast.Keywords.kwd_true()
      ast.Keywords.kwd_try()
      ast.Keywords.kwd_type()
      ast.Keywords.kwd_until()
      ast.Keywords.kwd_use()
      ast.Keywords.kwd_val()
      ast.Keywords.kwd_var()
      ast.Keywords.kwd_where()
      ast.Keywords.kwd_while()
      ast.Keywords.kwd_with()
      ast.Keywords.kwd_xor()
    ]

    let t = _trivia.trivia
    _keywords = Map[String, NamedRule]
    for str in _kwd_strings.values() do
      _add_rule("Keyword_" + str, str, t, _keywords)
    end

    _build_kwd()
    _build_not_kwd()
    _build_cap()
    _build_gencap()

  fun tag _add_rule(
    name: String,
    str: String,
    t: NamedRule,
    m: Map[String, NamedRule])
  =>
    let rule =
      NamedRule(name,
        _Build.with_post[ast.Trivia](
          Conj(
            [ Literal(str)
              Neg(Single(_Letters.with_underscore())) ]),
          t,
          {(d, r, c, b, p) =>
            let src_info = _Build.info(d, r)
            let value = ast.NodeWith[ast.Keyword](
              src_info, _Build.span_and_post(src_info, c, p), ast.Keyword(str)
              where post_trivia' = p)
            (value, b) })
        where memoize_failures' = false)
    m.insert(str, rule)

  fun apply(str: String): NamedRule box =>
    try
      _keywords(str)?
    else
      let msg =
        recover val
          "INVALID KEYWORD '" + StringUtil.escape(str) +
            "'; add it to the list in KeywordBuilder"
        end
      NamedRule(msg, Error(msg))
    end

  fun ref _build_kwd() =>
    let literals = Array[Literal box](_kwd_strings.size())
    for str in _kwd_strings.values() do
      literals.push(Literal(str))
    end

    kwd.set_body(
      _Build.with_post[ast.Trivia](
        Conj([ Disj(literals); Neg(Single(_Id.chars())) ]),
        _trivia.trivia,
        {(d, r, c, b, p) =>
          let src_info = _Build.info(d, r)
          let next =
            try
              p(0)?.src_info().start
            else
              src_info.next
            end
          let str =
            match (src_info.start, next)
            | (let s': Loc, let n': Loc) =>
              recover val String .> concat(s'.values(n')) end
            else
              ""
            end
          let value = ast.NodeWith[ast.Keyword](
            src_info, _Build.span_and_post(src_info, c, p), ast.Keyword(str)
            where post_trivia' = p)
          (value, b) }))

  fun ref _build_not_kwd() =>
    not_kwd.set_body(Neg(kwd))

  fun ref _build_cap() =>
    let kwd_iso = this(ast.Keywords.kwd_iso())
    let kwd_trn = this(ast.Keywords.kwd_trn())
    let kwd_ref = this(ast.Keywords.kwd_ref())
    let kwd_val = this(ast.Keywords.kwd_val())
    let kwd_box = this(ast.Keywords.kwd_box())
    let kwd_tag = this(ast.Keywords.kwd_tag())

    cap.set_body(
      Disj([
        kwd_iso
        kwd_trn
        kwd_ref
        kwd_val
        kwd_box
        kwd_tag
      ]))

  fun ref _build_gencap() =>
    let kwd_read = this(ast.Keywords.kwd_hash_read())
    let kwd_send = this(ast.Keywords.kwd_hash_send())
    let kwd_share = this(ast.Keywords.kwd_hash_share())
    let kwd_alias = this(ast.Keywords.kwd_hash_alias())
    let kwd_any = this(ast.Keywords.kwd_hash_any())

    gencap.set_body(
      Disj(
        [ kwd_read
          kwd_send
          kwd_share
          kwd_alias
          kwd_any
        ]))
