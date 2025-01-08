use ast = "../ast"

primitive _TypedefActions
  fun tag _doc_string(
    s: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let s' =
      try
        _Build.value_with[ast.LiteralString](b, s)?
      else
        return _Build.bind_error(d, r, c, b, "DocString/LiteralString")
      end

    ast.NodeWith[ast.DocString](
      _Build.info(d, r), c, ast.DocString(s'))

  fun tag _method_params(
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let params' = _Build.nodes_with[ast.MethodParam](c)

    ast.NodeWith[ast.MethodParams](
      _Build.info(d, r), c, ast.MethodParams(params'))

  fun tag _method_param(
    identifier: Variable,
    constraint: Variable,
    initializer: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let identifier' =
      try
        _Build.value_with[ast.Identifier](b, identifier)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/MethodParam/Identifier")
      end
    let constraint' = _Build.value_with_or_none[ast.TypeType](b, constraint)
    let initializer' =
      _Build.value_with_or_none[ast.Expression](b, initializer)

    ast.NodeWith[ast.MethodParam](
      _Build.info(d, r), c, ast.MethodParam(identifier', constraint', initializer'))

  fun tag _field(
    kind: Variable,
    identifier: Variable,
    constraint: Variable,
    initializer: Variable,
    doc_string: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let kind' =
      try
        _Build.value_with[ast.Keyword](b, kind)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Field/Kind")
      end
    let identifier' =
      try
        _Build.value_with[ast.Identifier](b, identifier)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Field/Identifier")
      end
    let constraint' = _Build.value_with_or_none[ast.TypeType](b, constraint)
    let initializer' = _Build.value_with_or_none[ast.Expression](b, initializer)
    let doc_strings' = _Build.values_with[ast.DocString](b, doc_string)

    ast.NodeWith[ast.TypedefField](
      _Build.info(d, r),
      c,
      ast.TypedefField(kind', identifier', constraint', initializer')
      where doc_strings' = doc_strings')

  fun tag _method(
    kind: Variable,
    ann: Variable,
    cap: Variable,
    raw: Variable,
    id: Variable,
    tparams: Variable,
    params: Variable,
    rtype: Variable,
    partial: Variable,
    doc_string: Variable,
    body: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let kind' =
      try
        _Build.value_with[ast.Keyword](b, kind)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Method/Kind")
      end
    let ann' = _Build.value_with_or_none[ast.Annotation](b, ann)
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap)
    let raw' = b.contains(raw)
    let id' =
      try
        _Build.value_with[ast.Identifier](b, id)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Method/Id")
      end
    let tparams' = _Build.value_with_or_none[ast.TypeParams](b, tparams)
    let params' = _Build.value_with_or_none[ast.MethodParams](b, params)
    let rtype' = _Build.value_with_or_none[ast.TypeType](b, rtype)
    let partial' = b.contains(partial)
    let doc_strings' = _Build.values_with[ast.DocString](b, doc_string)
    let body' = _Build.value_with_or_none[ast.Expression](b, body)

    ast.NodeWith[ast.TypedefMethod](
      _Build.info(d, r),
      c,
      ast.TypedefMethod(
        kind', cap', raw', id', tparams', params', rtype', partial', body')
      where doc_strings' = doc_strings', annotation' = ann')

  fun tag _members(
    fields: Variable,
    methods: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let fields' = _Build.values_with[ast.TypedefField](b, fields)
    let methods' = _Build.values_with[ast.TypedefMethod](b, methods)

    ast.NodeWith[ast.TypedefMembers](
      _Build.info(d, r), c, ast.TypedefMembers(fields', methods'))

  fun tag _primitive(
    an: Variable,
    id: Variable,
    tp: Variable,
    cs: Variable,
    ds: Variable,
    mm: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let an' = _Build.value_with_or_none[ast.Annotation](b, an)
    let id': ast.NodeWith[ast.Identifier] =
      try
        _Build.value_with[ast.Identifier](b, id)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Primitive/Identifier")
      end
    let tp' = _Build.value_with_or_none[ast.TypeParams](b, tp)
    let cs' = _Build.value_with_or_none[ast.TypeType](b, cs)
    let ds' = _Build.values_with[ast.DocString](b, ds)
    let mm' = _Build.value_with_or_none[ast.TypedefMembers](b, mm)

    ast.NodeWith[ast.Typedef](
      _Build.info(d, r), c, ast.TypedefPrimitive(id', tp', cs', mm')
      where annotation' = an', doc_strings' = ds')

  fun tag _alias(
    ann: Variable,
    id: Variable,
    tparams: Variable,
    type_type: Variable,
    doc_string: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let ann' = _Build.value_with_or_none[ast.Annotation](b, ann)
    let id' =
      try
        _Build.value_with[ast.Identifier](b, id)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Alias/Identifier")
      end
    let tparams' = _Build.value_with_or_none[ast.TypeParams](b, tparams)
    let type_type' =
      try
        _Build.value_with[ast.TypeType](b, type_type)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Alias/Type")
      end
    let doc_strings' = _Build.values_with[ast.DocString](b, doc_string)

    ast.NodeWith[ast.Typedef](
      _Build.info(d, r), c, ast.TypedefAlias(id', tparams', type_type')
      where annotation' = ann', doc_strings' = doc_strings')

  fun tag _class(
    kind: Variable,
    ann: Variable,
    raw: Variable,
    cap: Variable,
    id: Variable,
    tparams: Variable,
    constraint: Variable,
    doc_string: Variable,
    members: Variable,
    d: Data,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : (ast.Node | None)
  =>
    let kind' =
      try
        _Build.value_with[ast.Keyword](b, kind)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Class/Kind")
      end
    let ann' = _Build.value_with_or_none[ast.Annotation](b, ann)
    let raw' = b.contains(raw)
    let cap' = _Build.value_with_or_none[ast.Keyword](b, cap)
    let id' =
      try
        _Build.value_with[ast.Identifier](b, id)?
      else
        return _Build.bind_error(d, r, c, b, "Typedef/Class/Identifier")
      end
    let tparams' = _Build.value_with_or_none[ast.TypeParams](b, tparams)
    let constraint' = _Build.value_with_or_none[ast.TypeType](b, constraint)
    let doc_strings' = _Build.values_with[ast.DocString](b, doc_string)
    let members' = _Build.value_with_or_none[ast.TypedefMembers](b, members)

    ast.NodeWith[ast.Typedef](
      _Build.info(d, r),
      c,
      ast.TypedefClass(
        kind',
        raw',
        cap',
        id',
        tparams',
        constraint',
        members')
      where annotation' = ann', doc_strings' = doc_strings')
