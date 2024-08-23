use json = "../../../../json"

use ".."

interface val GeneralClientCapabilities
  fun val staleRequestSupport(): (StaleRequestSupport | None)
  fun val regularExpressions(): (RegularExpressionsClientCapabilities | None)
  fun val markdown(): (MarkdownClientCapabilities | None)
  fun val positionEncodings(): (Array[PositionEncodingKind] val | None)

primitive ParseGeneralClientCapabilities
  fun apply(obj: json.Object val): (GeneralClientCapabilities | String) =>
    let staleRequestSupport' =
      try
        match obj("staleRequestSupport")?
        | let srs_obj: json.Object val =>
          match ParseStaleRequestSupport(srs_obj)
          | let srs: StaleRequestSupport =>
            srs
          | let err: String =>
            return err
          end
        else
          return "staleRequestSupport must be a JSON object"
        end
      end
    let regularExpressions' =
      try
        match obj("regularExpressions")?
        | let re_obj: json.Object val =>
          match ParseRegularExpressionsClientCapabilities(re_obj)
          | let re: RegularExpressionsClientCapabilities =>
            re
          | let err: String =>
            return err
          end
        else
          return "regularExpressions must be a JSON object"
        end
      end
    let markdown' =
      try
        match obj("markdown")?
        | let md_obj: json.Object val =>
          match ParseMarkdownClientCapabilities(md_obj)
          | let md: MarkdownClientCapabilities =>
            md
          | let err: String =>
            return err
          end
        else
          return "markdown must be a JSON object"
        end
      end
    let positionEncodings': (Array[PositionEncodingKind] val | None) =
      try
        match obj("positionEncodings")?
        | let pe_seq: json.Sequence val =>
          let encs: Array[PositionEncodingKind] trn =
            Array[PositionEncodingKind]
          for item in pe_seq.values() do
            match ParsePositionEncodingKind(item)
            | let pek: PositionEncodingKind =>
              encs.push(pek)
            | let err: String =>
              return err
            end
          end
          consume encs
        else
          return "positionEncodings must be a JSON object"
        end
      end
    object val is GeneralClientCapabilities
      fun val staleRequestSupport(): (StaleRequestSupport | None) =>
        staleRequestSupport'
      fun val regularExpressions():
        (RegularExpressionsClientCapabilities | None)
      =>
        regularExpressions'
      fun val markdown(): (MarkdownClientCapabilities | None) => markdown'
      fun val positionEncodings(): (Array[PositionEncodingKind] val | None) =>
        positionEncodings'
    end

interface val StaleRequestSupport
  fun val cancel(): Bool
  fun val retryOnContentModified(): Array[String] val

primitive ParseStaleRequestSupport
  fun apply(obj: json.Object): (StaleRequestSupport | String) =>
    let cancel' =
      try
        match obj("cancel")?
        | let b: Bool =>
          b
        else
          return "staleRequestSupport.cancel must be of type boolean"
        end
      else
        return "staleRequestSupport must contain 'cancel'"
      end
    let retryOnContentModified': Array[String] val =
      try
        match obj("retryOnContentModified")?
        | let r_seq: json.Sequence =>
          let reqs: Array[String] trn = Array[String]
          for r_item in r_seq.values() do
            match r_item
            | let s: String box =>
              reqs.push(s.clone())
            else
              return "retryOnContentModified must be an array of strings"
            end
          end
          consume reqs
        else
          return "staleRequestSupport.retryOnContentModified must be an array"
        end
      else
        return "staleRequestSupport must contain 'retryOnContentModified'"
      end
    object val is StaleRequestSupport
      fun val cancel(): Bool => cancel'
      fun val retryOnContentModified(): Array[String] val =>
        retryOnContentModified'
    end
