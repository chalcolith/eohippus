use parser = "../parser"
use types = "../types"

class val LiteralFloat is
  (Node & NodeTyped[LiteralFloat] & NodeValued[F64] & NodeParent)

  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)

  let _value: F64
  let _value_error: Bool

  let _children: NodeSeq
  let _int_part: (LiteralInteger | None)
  let _frac_part: (LiteralInteger | None)
  let _exp_sign: (Node | None)
  let _exponent: (LiteralInteger | None)

  new val create(src_info': SrcInfo, children': NodeSeq) =>
    _src_info = src_info'
    _ast_type = None

    _children = children'
    match try _children(0)? as LiteralInteger end
    | let ip: LiteralInteger =>
      _int_part = ip
      _frac_part = try _children(1)? as LiteralInteger end
      _exp_sign = try _children(2)? end
      _exponent = try _children(3)? as LiteralInteger end
      (_value, _value_error) = _get_float_value(ip, _frac_part, _exp_sign,
        _exponent)
    else
      _int_part = None
      _frac_part = None
      _exp_sign = None
      _exponent = None
      _value = 0.0
      _value_error = true
    end

  new val from(src_info': SrcInfo, value': F64, value_error': Bool = false) =>
    _src_info = src_info'
    _ast_type = None

    _children = recover Array[Node] end
    _int_part = None
    _frac_part = None
    _exp_sign = None
    _exponent = None
    _value = value'
    _value_error = value_error'

  new val _with_ast_type(float: LiteralFloat, ast_type': types.AstType) =>
    _src_info = float.src_info()
    _ast_type = ast_type'
    _children = float.children()
    _int_part = float.int_part()
    _frac_part = float.frac_part()
    _exp_sign = float.exp_sign()
    _exponent = float.exponent()
    _value = float.value()
    _value_error = float.value_error()

  fun src_info(): SrcInfo => _src_info

  fun has_error(): Bool => _value_error

  fun eq(other: box->Node): Bool =>
    match other
    | let lf: LiteralFloat =>
      (this._src_info == lf._src_info) and (this._value == lf._value)
        and (this._value_error == lf._value_error)
    else
      false
    end

  fun get_string(indent: String): String =>
    let type_name =
      match _ast_type
      | let type': types.AstType =>
        type'.string()
      else
        "?LiteralFloat?"
      end
    indent + "<LIT type=\"" + type_name + "\" value=\""
      + (if _value_error then " ?ERORR?" else _value.string() end) + "\"/>"

  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): LiteralFloat =>
    LiteralFloat._with_ast_type(this, ast_type')

  fun value(): F64 => _value
  fun value_error(): Bool => _value_error

  fun children(): NodeSeq => _children
  fun int_part(): (LiteralInteger | None) => _int_part
  fun frac_part(): (LiteralInteger | None) => _frac_part
  fun exp_sign(): (Node | None) => _exp_sign
  fun exponent(): (LiteralInteger | None) => _exponent

  fun tag _get_float_value(ip: LiteralInteger, fp: (LiteralInteger | None),
    es: (Node | None), ex: (LiteralInteger | None)) : (F64, Bool)
  =>
    var n = F64.from[U128](ip.value())
    var err: Bool = ip.value_error()

    var frac: F64 = 0.0
    match fp
    | let fp': LiteralInteger =>
      var fi = fp'.value()
      err = err or fp'.value_error()
      while fi > 0 do
        frac = (frac / 10.0) + (F64.from[U128](fi % 10) / 10.0)
        fi = fi / 10
      end
      n = n + frac
    end

    var sign: F64 = 1.0
    var expo: F64 = 0.0
    match es
    | let es': Node =>
      try
        if es'.src_info().start().apply()? == '-' then
          sign = -1.0
        end
      end
    end
    match ex
    | let ex': LiteralInteger =>
      expo = F64.from[U128](ex'.value())
      err = err or ex'.value_error()
    end
    let pow10 = F64(10.0).pow(expo * sign)
    n = n * pow10
    (n, err)
