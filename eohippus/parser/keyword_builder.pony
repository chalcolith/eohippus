use "collections"

use ast = "../ast"
use ".."

class KeywordBuilder
  let _kwd_strings: Array[String] val

  let _context: Context
  let _trivia: TriviaBuilder

  let _keywords: Map[String, NamedRule] val
  var _kwd: (NamedRule | None) = None
  var _not_kwd: (NamedRule | None) = None
  var _cap: (NamedRule | None) = None
  var _gencap: (NamedRule | None) = None

  new create(context: Context, trivia: TriviaBuilder) =>
    _context = context
    _trivia = trivia

    _kwd_strings = [
      ast.Keywords.kwd_addressof()
      ast.Keywords.kwd_and()
      ast.Keywords.kwd_as()
      ast.Keywords.kwd_box()
      ast.Keywords.kwd_break()
      ast.Keywords.kwd_compile_error()
      ast.Keywords.kwd_compile_intrinsic()
      ast.Keywords.kwd_consume()
      ast.Keywords.kwd_continue()
      ast.Keywords.kwd_digestof()
      ast.Keywords.kwd_do()
      ast.Keywords.kwd_else()
      ast.Keywords.kwd_elseif()
      ast.Keywords.kwd_end()
      ast.Keywords.kwd_error()
      ast.Keywords.kwd_false()
      ast.Keywords.kwd_hash_alias()
      ast.Keywords.kwd_hash_any()
      ast.Keywords.kwd_hash_read()
      ast.Keywords.kwd_hash_send()
      ast.Keywords.kwd_hash_share()
      ast.Keywords.kwd_if()
      ast.Keywords.kwd_ifdef()
      ast.Keywords.kwd_iftype()
      ast.Keywords.kwd_is()
      ast.Keywords.kwd_iso()
      ast.Keywords.kwd_loc()
      ast.Keywords.kwd_not()
      ast.Keywords.kwd_or()
      ast.Keywords.kwd_primitive()
      ast.Keywords.kwd_ref()
      ast.Keywords.kwd_recover()
      ast.Keywords.kwd_repeat()
      ast.Keywords.kwd_return()
      ast.Keywords.kwd_tag()
      ast.Keywords.kwd_then()
      ast.Keywords.kwd_this()
      ast.Keywords.kwd_trn()
      ast.Keywords.kwd_true()
      ast.Keywords.kwd_try()
      ast.Keywords.kwd_until()
      ast.Keywords.kwd_use()
      ast.Keywords.kwd_val()
      ast.Keywords.kwd_where()
      ast.Keywords.kwd_while()
      ast.Keywords.kwd_xor()
    ]

    let t = _trivia.trivia()
    _keywords =
      recover val
        let k = Map[String, NamedRule]
        for str in _kwd_strings.values() do
          _add_rule("Keyword_" + str, str, t, k)
        end
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
              Conj(
                [ Literal(str)
                  Neg(Single(_Letters.with_underscore())) ])
            end,
            t,
            {(r, c, b, p) =>
              let value = ast.NodeWith[ast.Keyword](
                _Build.info(r), c, ast.Keyword(str)
                where post_trivia' = p)
              (value, b) }))
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
      let trivia = _trivia.trivia()
      let kwd' =
        recover val
          let literals =
            recover val
              let literals' = Array[Literal](_kwd_strings.size())
              for str in _kwd_strings.values() do
                literals'.push(Literal(str))
              end
              literals'
            end

          let str = Variable("str")

          NamedRule(
            "Keyword",
            _Build.with_post[ast.Trivia](
              recover val
                Bind(str, Disj(literals))
              end,
              trivia,
              {(r, c, b, p) =>
                let src_info = _Build.info(r)
                let next =
                  try
                    p(0)?.src_info().start
                  else
                    src_info.next
                  end
                let string =
                  recover val
                    String .> concat(src_info.start.values(next))
                  end
                let value = ast.NodeWith[ast.Keyword](
                  src_info, c, ast.Keyword(string)
                  where post_trivia' = p)
                (value, b) }))
        end
      _kwd = kwd'
      kwd'
    end

  fun ref not_kwd(): NamedRule =>
    match _not_kwd
    | let r: NamedRule => r
    else
      let not_kwd' =
        recover val
          NamedRule("NotKeyword", Neg(kwd()))
        end
      _not_kwd = not_kwd'
      not_kwd'
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

  fun ref gencap(): NamedRule =>
    match _gencap
    | let r: NamedRule => r
    else
      let kwd_read = this(ast.Keywords.kwd_hash_read())
      let kwd_send = this(ast.Keywords.kwd_hash_send())
      let kwd_share = this(ast.Keywords.kwd_hash_share())
      let kwd_alias = this(ast.Keywords.kwd_hash_alias())
      let kwd_any = this(ast.Keywords.kwd_hash_any())

      let gencap' =
        recover val
          NamedRule("Keyword_Gencap",
            Disj([
              kwd_read
              kwd_send
              kwd_share
              kwd_alias
              kwd_any
            ]))
        end
      _gencap = gencap'
      gencap'
    end
