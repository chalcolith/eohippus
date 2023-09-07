use "collections"

primitive Subsumes
  fun apply(a: Item, b: Item, p: String = "/"): (Bool, String) =>
    """`a` subsumes `b` if `b` contains at least everything in `a`."""
    match a
    | let a_obj: Object box => _obj_subsumes(a_obj, b, p)
    | let a_seq: Sequence box => _seq_subsumes(a_seq, b, p)
    | let a_str: String => _str_subsumes(a_str, b, p)
    | let a_int: I128 => _int_subsumes(a_int, b, p)
    | let a_float: F64 => _float_subsumes(a_float, b, p)
    | let a_bool: Bool => _bool_subsumes(a_bool, b, p)
    end

  fun _obj_subsumes(a_obj: Object box, b: Item, p: String): (Bool, String) =>
    match b
    | let b_obj: Object box =>
      for (key, a_val) in a_obj.pairs() do
        let path = recover val p + "/" + key end
        try
          (let res, let err) = apply(a_val, b_obj(key)?, path)
          if not res then
            return (res, err)
          end
        else
          return (false, "rhs of " + path + " does not exist")
        end
      end
      return (true, "")
    end
    (false, "rhs at " + p + " is not an object")

  fun _seq_subsumes(a_seq: Sequence box, b: Item, p: String): (Bool, String) =>
    match b
    | let b_seq: Sequence box =>
      if b_seq.size() < a_seq.size() then
        return (false, "rhs at " + p + " does not have enough elements")
      end
      for i in Range[USize](0, a_seq.size()) do
        let path = recover val p + "/" + i.string() end
        try
          (let res, let err) = apply(a_seq(i)?, b_seq(i)?, path)
          if not res then
            return (res, err)
          end
        else
          return (false, "rhs at " + path + " does not exist")
        end
      end
      return (true, "")
    end
    (false, "rhs at " + p + " is not a sequence")

  fun _str_subsumes(a_str: String, b: Item, p: String): (Bool, String) =>
    match b
    | let b_str: String =>
      if a_str == b_str then
        return (true, "")
      else
        return (false, "'" + a_str + "' at " + p + " != '" + b_str + "'")
      end
    end
    (false, "rhs at " + p + " is not a string")

  fun _int_subsumes(a_int: I128, b: Item, p: String): (Bool, String) =>
    match b
    | let b_int: I128 =>
      if a_int == b_int then
        return (true, "")
      else
        return (false, a_int.string() + " at " + p + " != " + b_int.string())
      end
    end
    (false, "rhs at " + p + " is not an integer")

  fun _float_subsumes(a_float: F64, b: Item, p: String): (Bool, String) =>
    match b
    | let b_float: F64 =>
      if (a_float - b_float).abs() <= 0.000001 then
        return (true, "")
      else
        return
          (false, a_float.string() + " at " + p + " != " + b_float.string())
      end
    end
    (false, "rhs at " + p + " is not a float")

  fun _bool_subsumes(a_bool: Bool, b: Item, p: String): (Bool, String) =>
    match b
    | let b_bool: Bool =>
      if a_bool == b_bool then
        return (true, "")
      else
        return (false, a_bool.string() + " at " + p + " != " + b_bool.string())
      end
    end
    (false, "rhs at " + p + " is not a bool")
