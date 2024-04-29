use json = "../../../json"

interface val Message
  fun val jsonrpc(): String => "2.0"

interface val RequestMessage is Message
  fun val id(): (I128 | String val)
  fun val method(): String val

interface val RequestParams

interface val ResponseMessage is Message
  fun val id(): (I128 | String | None)
  fun val result(): (ResultData | None) => None
  fun val err(): (ResponseError | None) => None

interface val ResponseError
  fun val code(): I128
  fun val message(): String val
  fun val data(): (json.Item | None) => None

interface val ResultData
  fun val get_json(): json.Item

interface val StaticRegistrationOptions
  fun val id(): (String | None) => None

type DocumentUri is String
type Uri is String

type WorkDoneToken is (I128 | String)

primitive ResourceOperationCreate
primitive ResourceOperationRename
primitive ResourceOperationDelete

type ResourceOperationKind is
  (ResourceOperationCreate | ResourceOperationRename | ResourceOperationDelete)

primitive ParseResourceOperationKind
  fun apply(item: json.Item): (ResourceOperationKind | String) =>
    match item
    | "create" =>
      ResourceOperationCreate
    | "rename" =>
      ResourceOperationRename
    | "delete" =>
      ResourceOperationDelete
    else
      "resourceOperation must be one of ('create' | 'rename' | 'delete')"
    end

primitive FailureHandlingAbort
primitive FailureHandlingTransactional
primitive FailureHandlingTextOnlyTransactional
primitive FailureHandlingUndo

type FailureHandlingKind is
  ( FailureHandlingAbort
  | FailureHandlingTransactional
  | FailureHandlingTextOnlyTransactional
  | FailureHandlingUndo )

primitive ParseFailureHandlingKind
  fun apply(item: json.Item): (FailureHandlingKind | String) =>
    match item
    | "abort" =>
      FailureHandlingAbort
    | "transactional" =>
      FailureHandlingTransactional
    | "textOnlyTransactional" =>
      FailureHandlingTextOnlyTransactional
    | "undo" =>
      FailureHandlingUndo
    else
      "failureHandling must be one of ('abort' | 'transactional' | " +
      "'textOnlyTransactional' | 'undo')"
    end

primitive PositionEncodingUtf8
primitive PositionEncodingUtf16
primitive PositionEncodingUtf32

type PositionEncodingKind is
  (PositionEncodingUtf8 | PositionEncodingUtf16 | PositionEncodingUtf32)

primitive ParsePositionEncodingKind
  fun apply(item: json.Item): (PositionEncodingKind | String) =>
    match item
    | "utf-8" =>
      PositionEncodingUtf8
    | "utf8" =>
      PositionEncodingUtf8
    | "utf-16" =>
      PositionEncodingUtf16
    | "utf-32" =>
      PositionEncodingUtf32
    else
      return "positionEncoding must be one of ('utf-8' | 'utf-16' | 'utf-32')"
    end

primitive PositionEncodingKindJson
  fun apply(pek: (PositionEncodingKind | None)): json.Item =>
    match pek
    | PositionEncodingUtf8 =>
      "utf-8"
    | PositionEncodingUtf16 =>
      "utf-16"
    | PositionEncodingUtf32 =>
      "utf-32"
    | None =>
      json.Null
    end
