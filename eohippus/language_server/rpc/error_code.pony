primitive ErrorCode
  // https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#baseTypes

  fun parse_error(): I128 => -32700
  fun invalid_request(): I128 => -32600
  fun method_not_found(): I128 => -32601
  fun invalid_params(): I128 => -32602
  fun internal_error(): I128 => -32603

  fun server_not_initialized(): I128 => -32002
  fun unknown_error_code(): I128 => -32001
  fun request_failed(): I128 => -32803
  fun server_cancelled(): I128 => -32802
  fun content_modified(): I128 => -32801
  fun request_cancelled(): I128 => -32800
