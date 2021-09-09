primitive ErrorMsg
  fun tag literal_integer_hex_empty(): String val =>
    "you must supply some hexadecimal digits here"

  fun tag literal_integer_bin_empty(): String val =>
    "you must supply some binary digits here"

  fun tag literal_char_empty(): String val =>
    "a character literal cannot be empty"

  fun tag literal_char_unterminated(): String val =>
    "expected a \"'\" character to end the character literal"

  fun tag literal_char_escape_invalid(): String val =>
    "invalid character escape sequence"
