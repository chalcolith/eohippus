primitive ErrorMsg
  fun tag internal_ast_node_not_bound(name: String): String =>
    "internal error: no AST node bound: " + name

  fun tag literal_integer_hex_empty(): String =>
    "you must supply some hexadecimal digits here"

  fun tag literal_integer_bin_empty(): String =>
    "you must supply some binary digits here"

  fun tag literal_char_empty(): String =>
    "a character literal cannot be empty"

  fun tag literal_char_unterminated(): String =>
    "expected a \"'\" character to end the character literal"

  fun tag literal_string_unterminated(): String =>
    "expected \" or \"\"\" to end the string literal"

  fun tag literal_char_escape_invalid(): String =>
    "invalid character escape sequence"

  fun tag literal_char_unicode_invalid(): String =>
    "invalid unicode escape sequence; must have 4 or 6 hexadecimal characters"

  fun tag exp_object_unterminated(): String =>
    "unterminated object literal"

  fun tag src_file_docstring_multiple(): String =>
    "you cannot have multiple docstrings"

  fun tag src_file_expected_docstring_using_or_typedef(): String =>
    "expected either a docstring, a \"use\" statement, or a type definition"

  fun tag src_file_expected_using_or_typedef(): String =>
    "expected either a \"use\" statement or a type definition"

  fun tag src_file_expected_typedef(): String =>
    "expected a type definition"

  fun tag src_file_expected_field_or_method(): String =>
    "expected a field or a method"

  fun tag src_file_expected_method(): String =>
    "expected a method"
