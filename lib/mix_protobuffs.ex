defmodule Mix.Tasks.Compile.Protobuffs do
  use Mix.Task

  @recursive true

  @impl true
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, [strict: [force: :boolean, output_pb_source: :boolean]])
    Mix.Task.run("loadpaths")
    Mix.Project.build_structure()

    output_include_dir = "include"
    output_ebin_dir = Mix.Project.compile_path()
    output_src_dir = Path.join(Path.dirname(output_ebin_dir), "src")
    File.mkdir_p!(output_src_dir)

    config = Mix.Project.config()
    dirs = config[:elixirc_paths] ++ config[:erlc_paths] ++ ["proto"]
    protos = Mix.Utils.extract_files(dirs, "*.proto")

    for proto <- protos do
      name = proto |> Path.basename() |> Path.rootname()
      output_include = Path.join(output_include_dir, name <> "_pb.hrl")
      output_beam = Path.join(output_ebin_dir, name <> ".beam")
      output_src = Path.join(output_src_dir, name <> "_pb.erl")

      protobuffs_opts = [
        {:output_include_dir, String.to_charlist(output_include_dir)},
        {:output_ebin_dir, String.to_charlist(output_ebin_dir)},
        {:output_src_dir, String.to_charlist(output_src_dir)},
        {:compile_flags, [:debug_info]}
      ]

      if opts[:force] || Mix.Utils.stale?([proto], [output_include, output_beam]) do
        :ok = :protobuffs_compile.scan_file(String.to_charlist(proto), protobuffs_opts)
      end

      if opts[:output_pb_source] && (opts[:force] || Mix.Utils.stale?([proto], [output_src])) do
        :ok = :protobuffs_compile.generate_source(String.to_charlist(proto), protobuffs_opts)
      end

      descriptor = Path.rootname(proto) <> "_desc.pb"

      if Mix.Utils.stale?([proto], [descriptor]) do
        Mix.Task.run("cmd", ["protoc", "-o", descriptor, proto])
      end
    end

    :ok
  end
end
