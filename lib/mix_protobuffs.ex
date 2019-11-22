defmodule Mix.Tasks.Compile.Protobuffs do
  use Mix.Task

  @recursive true

  @impl true
  def run(_opts) do
    Mix.Task.run("loadpaths")
    Mix.Project.build_structure()

    output_include_dir = "include"
    output_ebin_dir = Mix.Project.compile_path()

    config = Mix.Project.config()
    dirs = config[:elixirc_paths] ++ config[:erlc_paths] ++ ["proto"]
    protos = Mix.Utils.extract_files(dirs, "*.proto")

    for proto <- protos do
      name = proto |> Path.basename() |> Path.rootname()
      output_include = Path.join(output_include_dir, name <> "_pb.hrl")
      output_beam = Path.join(output_ebin_dir, name <> ".beam")

      if Mix.Utils.stale?([proto], [output_include, output_beam]) do
        :ok =
          :protobuffs_compile.scan_file(String.to_charlist(proto), [
            {:output_include_dir, String.to_charlist(output_include_dir)},
            {:output_ebin_dir, String.to_charlist(output_ebin_dir)}
          ])
      end

      descriptor = Path.rootname(proto) <> "_desc.pb"

      if Mix.Utils.stale?([proto], [descriptor]) do
        Mix.Task.run("cmd", ["protoc", "-o", descriptor, proto])
      end
    end

    :ok
  end
end
