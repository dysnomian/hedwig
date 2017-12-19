defmodule Hedwig.Adapters.Console do
  @moduledoc """
  Hedwig Console Adapter

  The console adapter is useful for testing out responders without a remote
  chat service.

      config :my_app, MyApp.Robot,
        adapter: Hedwig.Adapters.Console,
        ...

  Start your application with `mix run --no-halt` and you will have a console
  interface to your bot.
  """
  use Hedwig.Adapter
  alias Hedwig.Adapters.Console.Connection

  @doc false
  def init({robot, opts}) do
    {:ok, conn} = Connection.start(opts)
    Kernel.send(self(), :connected)
    {:ok, %{conn: conn, opts: opts, robot: robot}}
  end

  @doc false
  def handle_cast({:send, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  def handle_cast({:send_ephemeral, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  def handle_cast({:send_dm, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  @doc false
  def handle_cast({:reply, %{user: user, text: text} = msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, %{msg | text: "#{user}: #{text}"}})
    {:noreply, state}
  end

  def handle_cast({:dm_reply, %{user: user, text: text} = msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, %{msg | text: "DM to #{user}: #{text}"}})
    {:noreply, state}
  end

  def handle_cast({:threaded_reply, %{user: user, text: text, timestamp: ts} = msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, %{msg | text: "[#{ts}] #{user}: #{text}"}})
    {:noreply, state}
  end

  def handle_cast({:react, %{user: user, room: room, timestamp: ts, name: name} = reaction}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, %Hedwig.Message{user: user, text: "[#{ts}] #{user}: +:#{name}:"}})
    {:noreply, state}
  end

  def handle_cast({:emote, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  def handle_cast({:set_status, status}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, status})
    {:noreply, state}
  end

  def handle_cast({:set_topic, topic}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, topic})
    {:noreply, state}
  end

  def handle_cast({:join, room}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, room})
    {:noreply, state}
  end

  def handle_cast({:leave, room}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, room})
    {:noreply, state}
  end

  @doc false
  def handle_info({:message, %{"text" => text, "user" => user}}, %{robot: robot} = state) do
    msg = %Hedwig.Message{
      ref: make_ref(),
      robot: robot,
      text: text,
      type: "chat",
      user: user
    }

    Hedwig.Robot.handle_in(robot, msg)

    {:noreply, state}
  end

  def handle_info({:reaction, %{message: msg, room: room, timestamp: ts}, name}, %{robot: robot} = state) do
    reaction = %Hedwig.Reaction{
      ref: make_ref(),
      robot: robot,
      room: msg.room,
      name: name,
      timestamp: ts,
      type: "chat",
    }

    Hedwig.Robot.handle_in(robot, reaction)

    {:noreply, state}
  end

  def handle_info(:connected, %{robot: robot} = state) do
    :ok = Hedwig.Robot.handle_connect(robot)
    {:noreply, state}
  end
end
