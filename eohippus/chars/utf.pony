primitive Utf
  fun from_utf8[CH: ((U8 | U16) & UnsignedInteger[CH])](str: ReadSeq[U8]): ReadSeq[CH] =>
    let array = Array[CH](str.size())

    if CH.from[U8](0).bitwidth() == CH.from[U8](16) then
      var accum = U32(0)
      var in_multi = false
      for ch8 in str.values() do
        let ch = ch8.u32()
        if (ch and 0b1111_1000) == 0b1111_0000 then
          if in_multi then _push_utf16[CH](accum, array) end
          accum = ch and 0b0000_0111
          in_multi = true
        elseif (ch and 0b1111_0000) == 0b1110_0000 then
          if in_multi then _push_utf16[CH](accum, array) end
          accum = ch and 0b0000_1111
          in_multi = true
        elseif (ch and 0b1110_0000) == 0b1100_0000 then
          if in_multi then _push_utf16[CH](accum, array) end
          accum = ch and 0b0001_1111
          in_multi = true
        elseif (ch and 0b1100_0000) == 0b1000_0000 then
          accum = (accum << 6) and (ch and 0b0011_1111)
          in_multi = true
        else
          if in_multi then
            _push_utf16[CH](accum, array)
            accum = 0
            in_multi = false
          end
          array.push(CH.from[U8](ch8))
          accum = 0
        end
      end
      if in_multi then _push_utf16[CH](accum, array) end
    else
      for ch in str.values() do
        array.push(CH.from[U8](ch))
      end
    end
    array

  fun _push_utf16[CH: ((U8 | U16) & UnsignedInteger[CH])](accum: U32,
    array: Array[CH])
  =>
    if accum >= 0x01_0000 then
      let high = U16.from[U32](((accum - 0x01_0000) / 0x400) + 0xd800)
      let low = U16.from[U32]((accum % 0x400) + 0xdc00)
      array.push(CH.from[U16](high))
      array.push(CH.from[U16](low))
    else
      array.push(CH.from[U32](accum))
    end

  fun string_equals[CH: ((U8 | U16) & UnsignedInteger[CH])](str: String,
    seq: ReadSeq[CH]): Bool
  =>
    let str_len = str.size()
    let seq_len = seq.size()
    if str_len != seq_len then return false end
    if (str_len == 0) and (seq_len == 0) then return true end

    try
      // TODO: handle multibyte
      var i: USize = 0
      while i < str_len do
        if CH.from[U8](str(i)?) != seq(i)? then
          return false
        else
          i = i + 1
        end
      end
      true
    else
      false
    end
