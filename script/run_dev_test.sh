# Initial setup

rm -rf _build

rm -rf cover

rm -rf deps

mix local.hex --force

mix local.rebar --force

mix deps.get

mix compile

mix test
