primitive _Utils
  fun ch_seq[CH : ((U8 | U16) & UnsignedInteger[CH])](str: String): ReadSeq[CH] val =>
    recover
      let result = Array[CH](str.size())
      for ch in str.values() do
        result.push(CH.from[U8](ch))
      end
      result
    end
