# Initial setup

rm -rf _build

rm -rf cover

rm -rf deps

mix local.hex --force

mix local.rebar --force

mix deps.get

mix compile

# Custom tasks (like DB migrations)
mix ecto.setup

# Finally run the server
iex -S mix phx.server
