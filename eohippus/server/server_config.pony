use "files"

class val ServerConfig
  let ponyc_executable: (String | None)

  new create(ponyc_executable': (String | None)) =>
    ponyc_executable = ponyc_executable'

primitive ServerUtils
  fun get_pony_path(env: Env): ReadSeq[FilePath] val =>
    let pony_path: Array[FilePath] trn = []
    for env_var in env.vars.values() do
      if
        env_var.compare_sub("PONYPATH", 8 where ignore_case = true) is Equal
      then
        try
          let index = env_var.find("=")?
          for
            dir_path in Path.split_list(env_var.substring(index + 1)).values()
          do
            let fp = FilePath(FileAuth(env.root), dir_path)
            if fp.exists() then
              pony_path.push(fp)
            end
          end
        end
      end
    end
    consume pony_path

  fun find_ponyc(env: Env): (FilePath | None) =>
    for env_var in env.vars.values() do
      if env_var.compare_sub("PATH", 4 where ignore_case = true) is Equal then
        try
          let index = env_var.find("=")?
          for path_path in
            Path.split_list(env_var.substring(index + 1)).values()
          do
            let ponyc_path =
              ifdef windows then
                Path.join(path_path, "ponyc.exe")
              else
                Path.join(path_path, "ponyc")
              end
            let ponyc_file_path = FilePath(FileAuth(env.root), ponyc_path)
            if ponyc_file_path.exists() then
              return
                try
                  ponyc_file_path.canonical()?
                else
                  ponyc_file_path
                end
            end
          end
        end
      end
    end
