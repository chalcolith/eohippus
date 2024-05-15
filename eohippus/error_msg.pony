primitive ErrorMsg
  """The source of truth for error messages."""

  fun tag internal_ast_node_not_bound(name: String): String =>
    "Internal error: no AST node bound: " + name

  fun tag internal_ast_pass_clone(): String =>
    "Internal error: invalid node_data when cloning"

  fun tag literal_integer_hex_empty(): String =>
    "You must supply some hexadecimal digits here"

  fun tag literal_integer_bin_empty(): String =>
    "You must supply some binary digits here"

  fun tag literal_char_empty(): String =>
    "A character literal cannot be empty"

  fun tag literal_char_unterminated(): String =>
    "Expected a \"'\" character to end the character literal"

  fun tag literal_string_unterminated(): String =>
    "Expected \" or \"\"\" to end the string literal"

  fun tag literal_char_escape_invalid(): String =>
    "Invalid character escape sequence"

  fun tag literal_char_unicode_invalid(): String =>
    "Invalid unicode escape sequence; must have 4 or 6 hexadecimal characters"

  fun tag exp_object_unterminated(): String =>
    "Unterminated object literal"

  fun tag src_file_docstring_multiple(): String =>
    "You cannot have multiple docstrings"

  fun tag src_file_expected_docstring_using_or_typedef(): String =>
    "Expected either a docstring, a \"use\" statement, or a type definition"

  fun tag src_file_expected_using_or_typedef(): String =>
    "Expected either a \"use\" statement or a type definition"

  fun tag src_file_expected_typedef(): String =>
    "Expected a type definition"

  fun tag src_file_expected_field_or_method(): String =>
    "Expected a field or a method"

  fun tag src_file_expected_method(): String =>
    "Expected a method"
