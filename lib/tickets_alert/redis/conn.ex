defmodule TicketsAlert.Redis.Conn do
  @moduledoc nil

  @url_redis Application.compile_env!(:tickets_alert, :redis)[:connection_url]

  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, @url_redis, name: :tickets_alert_redis)
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :tickets_alert_redis)
  end

  def init(opts) do
    {:ok, _pid} = Redix.start_link(opts)
  end

  @spec execute_command(Redix.command(), String.t() | nil) ::
          {:ok, Redix.Protocol.redis_value()}
          | {:error, atom() | Redix.Error.t() | Redix.ConnectionError.t()}
  def execute_command(cmd, _url) do
    GenServer.call(:tickets_alert_redis, {:command, cmd})
  end

  @spec execute_commands_in_transaction([Redix.command()]) ::
          {:ok, [Redix.Protocol.redis_value()]}
          | {:error, atom() | Redix.Error.t() | Redix.ConnectionError.t()}
  def execute_commands_in_transaction(commands) do
    GenServer.call(:tickets_alert_redis, {:transaction, commands})
  end

  def handle_call({:command, cmd}, _from, conn) do
    {:reply, Redix.command(conn, cmd), conn}
  end

  def handle_call({:transaction, commands}, _from, conn) do
    {:reply, Redix.transaction_pipeline(conn, commands), conn}
  end

  def handle_call(:getstate, _from, conn) do
    {:reply, conn, conn}
  end
end
