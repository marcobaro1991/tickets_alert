defmodule TicketsAlert.Redis.Redis do
  @moduledoc nil

  alias TicketsAlert.Redis.Conn, as: Redis
  alias Noether.Either

  require Logger

  @spec get_and_delete_value(String.t()) ::
          {:ok, String.t() | nil} | {:error, atom() | Redix.Error.t() | Redix.ConnectionError.t()}
  def get_and_delete_value(key) do
    key
    |> generate_key()
    |> (&[get_cmd(&1), delete_cmd(&1)]).()
    |> Redis.execute_commands_in_transaction()
    |> Either.map(&List.first/1)
  end

  @spec save(String.t(), String.t(), integer()) :: {:ok, String.t()} | {:error, atom()}
  def save(key, value, ttl) do
    key
    |> save_cmd(value, ttl)
    |> Redis.execute_command(nil)
    |> case do
      {:ok, value} ->
        {:ok, value}

      {:error, error} ->
        Logger.error("Fail to save on redis #{inspect(error)}}")
        {:error, :redis_error}
    end
  end

  @spec get(String.t()) :: {:ok, String.t()} | {:error, atom()}
  def get(key) do
    key
    |> get_cmd()
    |> Redis.execute_command(nil)
    |> case do
      {:ok, value} ->
        {:ok, value}

      {:error, error} ->
        Logger.error("Fail to get on redis #{inspect(error)}}")
        {:error, :redis_error}
    end
  end

  @spec exists(String.t()) :: {:ok, integer} | {:error, atom()}
  def exists(key) do
    key
    |> exists_cmd()
    |> Redis.execute_command(nil)
    |> case do
      {:ok, value} ->
        {:ok, value}

      {:error, error} ->
        Logger.error("Fail to check existence of key on redis #{inspect(error)}}")
        {:error, :redis_error}
    end
  end

  @spec save_cmd(String.t(), String.t(), integer()) :: Redix.command()
  def save_cmd(key, value, ttl), do: ["SETEX", key, ttl, value]

  @spec exists_cmd(String.t()) :: Redix.command()
  def exists_cmd(key), do: ["EXISTS", key]

  @spec delete_cmd(String.t()) :: Redix.command()
  def delete_cmd(key), do: ["DEL", key]

  @spec get_cmd(String.t()) :: Redix.command()
  def get_cmd(key), do: ["GET", key]

  @spec generate_key(String.t()) :: String.t()
  def generate_key(key), do: "rac:" <> key
end
