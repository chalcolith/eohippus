use "collections"
use "files"

type Config is Map[String, String]

primitive ConfigKey
  fun tag trim_trailing_whitespace(): String => "trim_trailing_whitespace"

primitive EditorConfig

  fun read(path: FilePath): (Config val | String) =>
    match OpenFile(path)
    | let file: File =>
      let config: Config trn = Config
      var in_pony = false
      for line in FileLines(file) do
        if line == "[*.pony]" then
          in_pony = true
        elseif try line(0)? == '[' else false end then
          in_pony = false
        elseif try (line(0)? == ';') or (line(0)? == '#') else false end then
          None
        elseif in_pony then
          match try line.find("=")? end
          | let index: ISize =>
            let key: String trn = line.substring(0, index)
            key.strip()
            let value: String trn = line.substring(index + 1)
            value.strip()
            config.update(consume key, consume value)
          end
        end
      end
      consume config
    else
      return "Error opening editorconfig file " + path.path
    end

  fun default(): Config val =>
    recover val
      Config
        .> update(ConfigKey.trim_trailing_whitespace(), "true")
    end
