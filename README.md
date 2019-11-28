# MixProtobuffs

```
defp deps do
  [
        {:mix_protobuffs, git: "https://github.com/rlipscombe/mix_protobuffs.git", runtime: false},
  ]
end
```

Or:

```
mix archive.install
```

Or:

```
mix do deps.get, compile, compile.protobuffs \
    && mix archive.install --force \
    && MIX_ARCHIVES=~/.kiex/mix/archives/elixir-1.9.1/ mix archive.install --force
```
