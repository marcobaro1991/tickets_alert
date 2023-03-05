alias TicketsAlert.Repo, as: Repo

alias TicketsAlert.Schema.Event
alias TicketsAlert.Schema.User

events = [
  %{
    identifier: "97ea8c69-daca-4dbe-9ca1-7682410653d4" |> UUID.string_to_binary!(),
    external_identifier: "fansale-expired-event",
    title: "fansale event expired",
    date: ~D[1970-01-01],
    provider: :fansale,
    enabled: true
  },
  %{
    identifier: "b02c2941-c952-416a-a74b-191afa2f8ced" |> UUID.string_to_binary!(),
    external_identifier: "fansale-expired-today-event",
    title: "fansale event expired today",
    date: DateTime.utc_now() |> DateTime.to_date(),
    provider: :fansale,
    enabled: true
  },
  %{
    identifier: "f92691fe-18ff-4a41-b4c3-a1d453433ec5" |> UUID.string_to_binary!(),
    external_identifier: "fansale-event-disabled",
    title: "fansale event disabled",
    date: ~D[2100-01-01],
    provider: :fansale,
    enabled: false
  },
  %{
    identifier: "10577cdd-54d3-44a2-a412-c7bd1e6a2bf9" |> UUID.string_to_binary!(),
    external_identifier: "fansale-not-valid-event",
    title: "fansale not valid event",
    date: ~D[1970-12-25],
    provider: :fansale,
    enabled: false
  },
  %{
    identifier: "96c547c4-fd6c-4a94-a009-1e28c4901b14" |> UUID.string_to_binary!(),
    external_identifier: "fansale-valid-event",
    title: "fansale valid event",
    date: ~D[2100-12-25],
    provider: :fansale,
    enabled: true
  }
]

users = [
  %{
    identifier: "6dd39b15-8e58-49d2-85b4-718e36af2c6b" |> UUID.string_to_binary!(),
    first_name: "Marco",
    last_name: "Baroni",
    password: "+xTjvH3hKDWqpqzV4at4Hg==",
    email: "baroni.marco.91+active@gmail.com",
    registration_type: :default,
    status: :active
  },
  %{
    identifier: "5108058f-4b35-4ffd-8308-b2e5576693ff" |> UUID.string_to_binary!(),
    first_name: "Marco",
    last_name: "Baroni",
    password: "8hcTIZZNAhowzQFASRI3tQ==",
    email: "baroni.marco.91+not_active@gmail.com",
    registration_type: :default,
    status: :not_active
  }
]

Repo.insert_all(Event, events)
Repo.insert_all(User, users)
