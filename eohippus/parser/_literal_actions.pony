use "itertools"
use ast = "../ast"

primitive _LiteralActions
  fun tag _bool(
    r: Success,
    c: ast.NodeSeq,
    b: Bindings)
    : ((ast.Node | None), Bindings)
  =>
    let src_info = _Build.info(r)
    let string = src_info.literal_source()
    let true_str = ast.Keywords.kwd_true()
    let is_true = string.compare_sub(true_str, true_str.size()) == Equal
    let value = ast.NodeWith[ast.Literal](
      src_info, c, ast.LiteralBool(is_true))
    (value, b)

  fun tag _integer(
    hex: Variable,
    bin: Variable,
    dec: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings,
    p: ast.NodeSeqWith[ast.Trivia])
    : ((ast.Node | None), Bindings)
  =>
    let kind =
      if b.contains(hex) then
        ast.HexadecimalInteger
      elseif b.contains(bin) then
        ast.BinaryInteger
      else
        ast.DecimalInteger
      end
    let src_info = _Build.info(r)
    var str = src_info.literal_source(p)
    let base: U8 =
      match kind
      | ast.DecimalInteger =>
        10
      | ast.HexadecimalInteger =>
        str = str.trim(2)
        16
      | ast.BinaryInteger =>
        str = str.trim(2)
        2
      end
    let num: U128 = try str.u128(base)? else 0 end
    let value = ast.NodeWith[ast.Literal](
      src_info, c, ast.LiteralInteger(num, kind)
      where post_trivia' = p)
    (value, b)

  fun tag _float(
    int_part: Variable,
    frac_part: Variable,
    exp_sign: Variable,
    exponent: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings,
    p: ast.NodeSeqWith[ast.Trivia])
    : ((ast.Node | None), Bindings)
  =>
    let src_info = _Build.info(r)
    let str = src_info.literal_source(p)

    let int_result' = try _Build.result(b, int_part)? end
    let frac_result' = try _Build.result(b, frac_part)? end
    let exp_result' = try _Build.result(b, exponent)? end

    if (int_result' isnt None) and
       (frac_result' is None) and
       (exp_result' is None)
    then
      let int_num: U128 = try str.u128(10)? else 0 end
      let int_value = ast.NodeWith[ast.LiteralInteger](
        src_info, c, ast.LiteralInteger(int_num, ast.DecimalInteger)
        where post_trivia' = p)
      return (int_value, b)
    end

    let num: F64 = try str.f64()? else 0.0 end
    let value = ast.NodeWith[ast.Literal](
      src_info, c, ast.LiteralFloat(num)
      where post_trivia' = p)
    (value, b)

  fun tag _char(
    bod: Variable,
    uni: Variable,
    esc: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings,
    p: ast.NodeSeqWith[ast.Trivia])
    : ((ast.Node | None), Bindings)
  =>
    let br =
      try
        _Build.result(b, bod)?
      else
        r
      end

    var num: U32 = 0
    let str = recover val String .> concat(br.start.values(br.next)) end

    if b.contains(esc) then
      (_char_esc(r, br, c, p), b)
    elseif b.contains(uni) then
      (_char_uni(r, br, c, p), b)
    else
      for ch in br.start.values(br.next) do
        if (ch and 0b11111000) == 0b11110000 then
          num = (num << 3) or U32.from[U8](ch and 0b00000111)
        elseif (ch and 0b11100000) == 0b11100000 then
          num = (num << 4) or U32.from[U8](ch and 0b00001111)
        elseif (ch and 0b11100000) == 0b11000000 then
          num = (num << 5) or U32.from[U8](ch and 0b00011111)
        elseif (ch and 0b11000000) == 0b10000000 then
          num = (num << 6) or U32.from[U8](ch and 0b00111111)
        else
          num = (num << 8) or U32.from[U8](ch)
        end
      end
      let value = ast.NodeWith[ast.Literal](
        _Build.info(r), c, ast.LiteralChar(num, ast.CharLiteral)
        where post_trivia' = p)
      (value, b)
    end

  fun tag _char_esc(
    outer: Success,
    body: Success,
    c: ast.NodeSeq,
    p: ast.NodeSeqWith[ast.Trivia])
    : ast.NodeWith[ast.Literal]
  =>
    var num: U32 = 0
    var at_start = true
    var got_slash = false
    var is_hex = false

    for ch in body.start.values(body.next) do
      if at_start then
        at_start = false
        if ch == '\\' then
          got_slash = true
          continue
        end
      end

      if is_hex then
        if (ch >= '0') and (ch <= '9') then
          num = (num * 16) + U32.from[U8](ch - '0')
        elseif (ch >= 'a') and (ch <= 'f') then
          num = (num * 16) + U32.from[U8](ch - 'a') + 10
        elseif (ch >= 'A') and (ch <= 'F') then
          num = (num * 16) + U32.from[U8](ch - 'A') + 10
        end
      elseif got_slash then
        if (ch == 'x') or (ch == 'X') then
          is_hex = true
          continue
        elseif ch == 'a' then
          num = '\a'
        elseif ch == 'b' then
          num = '\b'
        elseif ch == 'e' then
          num = '\e'
        elseif ch == 'f' then
          num = '\f'
        elseif ch == 'n' then
          num = '\n'
        elseif ch == 'r' then
          num = '\r'
        elseif ch == '\t' then
          num = '\t'
        elseif ch == '\v' then
          num = '\v'
        elseif ch == '\\' then
          num = '\\'
        elseif ch == '0' then
          num = '\0'
        elseif ch == '\'' then
          num = '\''
        elseif ch == '"' then
          num = '"'
        end
        break
      end
    end

    ast.NodeWith[ast.Literal](
      _Build.info(outer), c, ast.LiteralChar(num, ast.CharEscaped)
      where post_trivia' = p)

  fun tag _char_uni(
    outer: Success,
    body: Success,
    c: ast.NodeSeq,
    p: ast.NodeSeqWith[ast.Trivia])
    : ast.NodeWith[ast.Literal]
  =>
    var num: U32 = 0
    for ch in (body.start + 2).values(body.next) do
      if (ch >= '0') and (ch <= '9') then
        num = (num * 16) + U32.from[U8](ch - '0')
      elseif (ch >= 'a') and (ch <= 'f') then
        num = (num * 16) + U32.from[U8](ch - 'a') + 10
      elseif (ch >= 'A') and (ch <= 'F') then
        num = (num * 16) + U32.from[U8](ch - 'A') + 10
      end
    end

    ast.NodeWith[ast.Literal](
      _Build.info(outer), c, ast.LiteralChar(num, ast.CharUnicode)
      where post_trivia' = p)

  fun tag _string(
    tri: Variable,
    r: Success,
    c: ast.NodeSeq,
    b: Bindings,
    p: ast.NodeSeqWith[ast.Trivia])
    : ((ast.Node | None), Bindings)
  =>
    let kind =
      if b.contains(tri) then
        ast.StringTripleQuote
      else
        ast.StringLiteral
      end
    // var first_token = true

    // assemble the string (with first indent if triple)
    let indented =
      recover val
        let indented' = String
        for child in c.values() do
          match child
          // | let tok: ast.NodeWith[ast.Token] =>
          //   if first_token then
          //     for t in tok.post_trivia().values() do
          //       let si = t.src_info()
          //       indented'.concat(si.start.values(si.next))
          //     end
          //     first_token = false
          //   end
          | let ch: ast.NodeWith[ast.Literal] =>
            match ch.data()
            | let chd: ast.LiteralChar =>
              indented'.push_utf32(chd.value())
            end
          | let sp: ast.NodeWith[ast.Span] =>
            let si = sp.src_info()
            indented'.concat(si.start.values(si.next))
          end
        end
        indented'
      end

    // remove indents from triple-quoted strings
    let outdented =
      if (kind is ast.StringTripleQuote) and (indented.size() > 0) then
        // get pairs of (start, next) for each line in the string
        let trimmed: String iso = String
        let lines = _string_lines(indented)
        if lines.size() > 1 then
          try
            (var start, var next) = lines(0)?
            let first_line = indented.trim(start, next - 1)
            let fli = Iter[U8](first_line.values())
            // if the first line is all whitespace, then ignore it,
            // and trim prefixes from from subseqent lines
            if fli.all({(ch) => (ch == ' ') or (ch == '\t') }) then
              (start, next) = lines(1)?
              let indent =
                recover val
                  let second_line = indented.trim(start, next - 1)
                  let sli = Iter[U8](second_line.values())
                  String .> concat(sli.take_while(
                    {(ch) => (ch == ' ') or (ch == '\t') }))
                end
              let isz = indent.size()

              var i: USize = 1
              while i < lines.size() do
                if i > 1 then trimmed.append("\n") end
                (let s, let n) = lines(i)?
                if indented.compare_sub(indent, isz, ISize.from[USize](s))
                  is Equal
                then
                  trimmed.append(indented.trim(s + isz, n - 1))
                else
                  trimmed.append(indented.trim(s, n - 1))
                end
                i = i + 1
              end
            end
          end
          consume trimmed
        else
          indented
        end
      else
        indented
      end

    let value = ast.NodeWith[ast.Literal](
      _Build.info(r), c, ast.LiteralString(outdented, kind)
      where post_trivia' = p)
    (value, b)

  fun tag _string_lines(str: String box): Array[(USize, USize)] val =>
    let result: Array[(USize, USize)] trn = Array[(USize, USize)]
    let size = str.size()
    var start_pos: USize = 0
    var next_pos: USize = 0
    var cur: USize = 0
    try
      while cur < size do
        let ch = str(cur)?
        if ch == '\n' then
          if ((cur+1) < size) and (str(cur+1)? == '\r') then
            next_pos = cur + 2
          else
            next_pos = cur + 1
          end
        elseif ch == '\r' then
          if ((cur+1) < size) and (str(cur+1)? == '\n') then
            next_pos = cur + 2
          else
            next_pos = cur + 1
          end
        else
          cur = cur + 1
          continue
        end
        result.push((start_pos, next_pos))
        start_pos = next_pos
        cur = next_pos
      end
      if start_pos < cur then
        result.push((start_pos, cur))
      end
    end
    consume result
