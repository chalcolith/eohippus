use "files"

class val ServerConfig
  let ponyc_executable: (FilePath | None)

  new create(ponyc_executable': (FilePath | None)) =>
    ponyc_executable = ponyc_executable'
