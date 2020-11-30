defmodule Mix.Tasks.Compile.Protobuffs do
  use Mix.Task.Compiler

  @shortdoc "Compiles protocol buffers"

  @moduledoc """
  Compiles protocol buffers.

  Looks for `.proto` files in the Elixir and Erlang source directories, and
  in the `proto` directory.

  Generates `{name}_pb.hrl` files in the `_build/.../include` directory,
  and `{name}_pb.beam` files in the `_build/.../ebin` directory.

  Generates `{name}_desc.pb` files in the same directory as the `.proto` file.

  Supports the `--force` flag.

  The `--output-pb-source` flag causes `{name}_pb.erl` to be written to
  the `_build/.../src` directory.
  """

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

    protos = find_protos()

    for proto <- protos do
      name = proto |> Path.basename() |> Path.rootname()
      output_include = Path.join(output_include_dir, name <> "_pb.hrl")
      output_beam = Path.join(output_ebin_dir, name <> "_pb.beam")
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

  @impl true
  def clean() do
    Mix.Task.run("loadpaths")

    output_include_dir = "include"
    output_ebin_dir = Mix.Project.compile_path()
    output_src_dir = Path.join(Path.dirname(output_ebin_dir), "src")

    protos = find_protos()

    for proto <- protos do
      name = proto |> Path.basename() |> Path.rootname()
      rm_file_if_exists!(Path.join(output_include_dir, name <> "_pb.hrl"))
      rm_file_if_exists!(Path.join(output_ebin_dir, name <> "_pb.beam"))
      rm_file_if_exists!(Path.join(output_src_dir, name <> "_pb.erl"))
      rm_file_if_exists!(Path.rootname(proto) <> "_desc.pb")
    end

    :ok
  end

  defp find_protos() do
    config = Mix.Project.config()
    dirs = config[:elixirc_paths] ++ config[:erlc_paths] ++ ["proto"]
    Mix.Utils.extract_files(dirs, "*.proto")
  end

  defp rm_file_if_exists!(path) do
    try do
      File.rm(path)
    rescue
      e in File.Error ->
        case e.reason do
          :enoent ->
            :ok
          _other ->
            reraise e, __STACKTRACE__
        end
    end
  end
end
