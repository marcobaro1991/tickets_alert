defmodule TicketsAlert.Graphql.Types.Custom.Date do
  @moduledoc false

  alias Noether.Either
  use Absinthe.Schema.Notation

  enum :month do
    value(:january)
    value(:february)
    value(:march)
    value(:april)
    value(:may)
    value(:june)
    value(:july)
    value(:august)
    value(:september)
    value(:october)
    value(:november)
    value(:december)
  end

  scalar :date, description: "date" do
    parse(&parse_date/1)
    serialize(&serialize_date/1)
  end

  scalar :time, description: "time" do
    parse(&parse_time/1)
    serialize(&serialize_time/1)
  end

  scalar :datetime, description: "ISO8601 time" do
    parse(&parse_datetime/1)
    serialize(&serialize_datetime/1)
  end

  @spec parse_date(map()) :: {:ok, Date.t()} | {:ok, nil} | {:error, String.t()}
  defp parse_date(%Absinthe.Blueprint.Input.Null{}), do: {:ok, nil}

  defp parse_date(%{value: value}) when is_nil(value) or value == "", do: {:ok, nil}

  defp parse_date(%{value: value}) do
    value
    |> Timex.parse("{YYYY}-{0M}-{0D}")
    |> Either.map(&NaiveDateTime.to_date/1)
  end

  @spec serialize_date(Date.t() | nil) :: nil | String.t()
  defp serialize_date(nil), do: nil
  defp serialize_date(date = %Date{}), do: Date.to_string(date)
  defp serialize_date(date) when is_binary(date), do: date

  @spec parse_time(map()) :: {:ok, Time.t()} | {:ok, nil} | {:error, String.t()}
  defp parse_time(%Absinthe.Blueprint.Input.Null{}), do: {:ok, nil}

  defp parse_time(%{value: value}) when is_nil(value) or value == "", do: {:ok, nil}

  defp parse_time(%{value: time}) do
    Time.from_iso8601("#{time}")
  end

  @spec serialize_time(nil | Time.t()) :: nil | String.t()
  defp serialize_time(nil), do: nil
  defp serialize_time(time = %Time{}), do: Time.to_string(time)
  defp serialize_time(time) when is_binary(time), do: time

  @spec parse_datetime(map()) :: {:ok, DateTime.t()} | {:ok, nil}
  defp parse_datetime(%Absinthe.Blueprint.Input.Null{}), do: {:ok, nil}
  defp parse_datetime(%{value: value}) when is_nil(value) or value == "", do: {:ok, nil}
  defp parse_datetime(%{value: value}), do: Timex.parse(value, "{ISO:Extended}")

  @spec serialize_datetime(Timex.Types.valid_datetime() | String.t()) :: binary
  def serialize_datetime(datetime = %{}) do
    datetime
    |> local_datetime()
    |> DateTime.truncate(:second)
    |> Timex.format!("{ISO:Extended}")
  end

  def serialize_datetime(datetime) when is_binary(datetime) do
    datetime
    |> Timex.parse!("{ISO:Extended}")
    |> DateTime.truncate(:second)
    |> Timex.format!("{ISO:Extended}")
  end

  @doc """
  Converte una data UTC in Europe/Rome gestendo correttamente gli edge cases dove la data cade in un cambio di ora
  """
  @spec local_datetime(Timex.Types.valid_datetime()) :: DateTime.t() | no_return()
  def local_datetime(datetime) do
    datetime
    |> Timex.to_datetime(timezone_info())
    |> case do
      %Timex.AmbiguousDateTime{before: before} -> before
      dt = %DateTime{} -> dt
    end
  end

  @spec timezone_info :: String.t() | no_return()
  defp timezone_info do
    "Europe/Rome"
    |> Timex.Timezone.get()
    |> case do
      %Timex.AmbiguousTimezoneInfo{before: %Timex.TimezoneInfo{full_name: full_name}} -> full_name
      %Timex.TimezoneInfo{full_name: full_name} -> full_name
      {:error, _} -> raise "Invalid timezone info"
    end
  end
end
