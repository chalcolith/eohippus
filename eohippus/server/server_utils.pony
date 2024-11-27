use "files"

primitive ServerUtils
  fun get_pony_path_dirs(env: Env): ReadSeq[FilePath] val =>
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

  fun find_pony_packages(
    env: Env,
    ponyc: (FilePath | None))
    : (FilePath | None)
  =>
    match ponyc
    | let ponyc_path: FilePath =>
      let zero_down = Path.split(ponyc_path.path)._1
      let one_down = Path.split(zero_down)._1
      var packages_path = FilePath(
        FileAuth(env.root), Path.join(one_down, "packages"))
      if packages_path.exists() then
        return packages_path
      end
      let two_down = Path.split(one_down)._1
      packages_path = FilePath(
        FileAuth(env.root), Path.join(two_down, "packages"))
      if packages_path.exists() then
        return packages_path
      end
    end
