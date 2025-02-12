use json = "../../../json"

use analyzer = "../../../analyzer"
use ".."

interface val Message
  fun val jsonrpc(): String => JsonRpc.version()

interface val Notification is Message
  fun val method(): String
  fun val params(): NotificationParams

interface val NotificationParams
  fun val get_json(): json.Item

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
  fun val message(): String
  fun val data(): (json.Item | None) => None

interface val ResultData is SendData

interface val SendData
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

interface val Location
  fun val uri(): DocumentUri
  fun val range(): Range

  fun val get_json(): json.Item =>
    json.Object(
      [ as (String, json.Item):
        ("uri", uri())
        ("range", range().get_json()) ])

interface val Range
  fun val start(): Position
  fun val endd(): Position

  fun val get_json(): json.Item =>
    json.Object(
      [ as (String, json.Item):
        ("start", start().get_json())
        ("end", endd().get_json()) ])

primitive ParseRange
  fun apply(obj: json.Object val): (Range | String) =>
    let start' =
      match try obj("start")? end
      | let start_obj: json.Object val =>
        match ParsePosition(start_obj)
        | let pos: Position =>
          pos
        | let err: String =>
          return err
        end
      else
        return "range.start must be an object"
      end
    let endd' =
      match try obj("end")? end
      | let end_obj: json.Object val =>
        match ParsePosition(end_obj)
        | let pos: Position =>
          pos
        | let err: String =>
          return err
        end
      else
        return "range.end must be an object"
      end
    object val is Range
      fun val start(): Position => start'
      fun val endd(): Position => endd'
    end

interface val Position
  fun val line(): I128
  fun val character(): I128

  fun val get_json(): json.Item =>
    json.Object(
      [ as (String, json.Item):
        ("line", line())
        ("character", character()) ])

primitive ParsePosition
  fun apply(obj: json.Object val): (Position | String) =>
    let line' =
      match try obj("line")? end
      | let int: I128 =>
        int
      else
        return "position.line must be an integer"
      end
    let character' =
      match try obj("character")? end
      | let int: I128 =>
        int
      else
        return "position.character must be an integer"
      end
    object val is Position
      fun val line(): I128 => line'
      fun val character(): I128 => character'
    end
