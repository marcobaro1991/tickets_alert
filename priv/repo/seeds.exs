alias TicketsAlert.Repo, as: Repo

alias TicketsAlert.Schema.Event

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

Repo.insert_all(Event, events)
