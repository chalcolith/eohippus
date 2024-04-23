use json = "../../../../json"

interface val MarkdownClientCapabilities
  fun val parser(): String
  fun val version(): (String | None)
  fun val allowedTags(): (Array[String] val | None)

primitive ParseMarkdownClientCapabilities
  fun apply(obj: json.Object): (MarkdownClientCapabilities | String) =>
    let parser': String =
      try
        match obj("parser")?
        | let s: String box =>
          s.clone()
        else
          return "markdown.parser must be of type string"
        end
      else
        return "markdown must contain a property 'parser'"
      end
    let version': (String | None) =
      try
        match obj("version")?
        | let s: String box =>
          s.clone()
        else
          return "markdown.version must be of type string"
        end
      end
    let allowedTags': (Array[String] val | None) =
      try
        match obj("allowedTags")?
        | let at_seq: json.Sequence =>
          let ats: Array[String] trn = Array[String]
          for at_item in at_seq.values() do
            match at_item
            | let s: String box =>
              ats.push(s.clone())
            else
              return "markdown.allowedTags must be strings"
            end
          end
          consume ats
        else
          return "markdown.allowedTags must be an array"
        end
      end
    object val is MarkdownClientCapabilities
      fun val parser(): String => parser'
      fun val version(): (String | None) => version'
      fun val allowedTags(): (Array[String] val | None) => allowedTags'
    end
