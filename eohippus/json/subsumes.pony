use "collections"

primitive Subsumes
  fun apply(a: Item, b: Item): Bool =>
    """`a` subsumes `b` if `b` contains at least everything in `a`."""
    match a
    | let a_obj: Object box => _obj_subsumes(a_obj, b)
    | let a_seq: Sequence box => _seq_subsumes(a_seq, b)
    | let a_str: String => _str_subsumes(a_str, b)
    | let a_int: I128 => _int_subsumes(a_int, b)
    | let a_float: F64 => _float_subsumes(a_float, b)
    | let a_bool: Bool => _bool_subsumes(a_bool, b)
    end

  fun _obj_subsumes(a_obj: Object box, b: Item): Bool =>
    try
      match b
      | let b_obj: Object box =>
        for (key, a_val) in a_obj.pairs() do
          if not apply(a_val, b_obj(key)?) then
            return false
          end
        end
        return true
      end
    end
    false

  fun _seq_subsumes(a_seq: Sequence box, b: Item): Bool =>
    try
      match b
      | let b_seq: Sequence box =>
        if b_seq.size() < a_seq.size() then
          return false
        end
        for i in Range[USize](0, a_seq.size()) do
          if not apply(a_seq(i)?, b_seq(i)?) then
            return false
          end
        end
        return true
      end
    end
    false

  fun _str_subsumes(a_str: String, b: Item): Bool =>
    match b
    | let b_str: String =>
      return a_str == b_str
    end
    false

  fun _int_subsumes(a_int: I128, b: Item): Bool =>
    match b
    | let b_int: I128 =>
      return a_int == b_int
    end
    false

  fun _float_subsumes(a_float: F64, b: Item): Bool =>
    match b
    | let b_float: F64 =>
      return (a_float - b_float).abs() <= 0.000001
    end
    false

  fun _bool_subsumes(a_bool: Bool, b: Item): Bool =>
    match b
    | let b_bool: Bool =>
      return a_bool == b_bool
    end
    false
