# MixProtobuffs

mix archive.install

mix do deps.get, compile, compile.protobuffs && mix archive.install --force && MIX_ARCHIVES=~/.kiex/mix/archives/elixir-1.9.1/ mix archive.install --force
