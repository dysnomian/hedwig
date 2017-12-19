defmodule Hedwig.Adapter do
  @moduledoc """
  Hedwig Adapter Behaviour

  An adapter is the interface to the service your bot runs on. To implement an
  adapter you will need to translate messages from the service to the
  `Hedwig.Message` struct and call `Hedwig.Robot.handle_message(robot, msg)`.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [send: 2]

      @behaviour Hedwig.Adapter
      use GenServer

      def send(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:send, msg})
      end

      def send_ephemeral(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:send_ephemeral, msg})
      end

      def send_dm(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:send_dm, msg})
      end

      def reply(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:reply, msg})
      end

      def direct_reply(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:dm_reply, msg})
      end

      def threaded_reply(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:dm_reply, msg})
      end

      def emote(pid, %Hedwig.Message{} = msg) do
        GenServer.cast(pid, {:emote, msg})
      end

      def react(pid, %Hedwig.Reaction{} = reaction) do
        GenServer.cast(pid, {:react, reaction})
      end

      def set_topic(pid, %{channel: channel, topic: topic} = msg) do
        GenServer.cast(pid, {:set_topic, msg})
      end

      def set_status(pid, %{user: user, text: text, emoji: emoji} = msg) do
        GenServer.cast(pid, {:set_status, msg})
      end

      # TODO: Joining rooms
      def join(pid, room) do
      end

      # TODO: Exiting rooms
      def leave(pid, room) do
      end

      @doc false
      def start_link(robot, opts) do
        Hedwig.Adapter.start_link(__MODULE__, opts)
      end

      @doc false
      def stop(pid, timeout \\ 5000) do
        ref = Process.monitor(pid)
        Process.exit(pid, :normal)
        receive do
          {:DOWN, ^ref, _, _, _} -> :ok
        after
          timeout -> exit(:timeout)
        end
        :ok
      end

      @doc false
      defmacro __before_compile__(_env) do
        :ok
      end

      defoverridable [__before_compile__: 1,
      send: 2, send_dm: 2, send_ephemeral: 2,
      reply: 2, direct_reply: 2, threaded_reply: 2,
      emote: 2, react: 2,
      set_topic: 2, set_status: 2,
      join: 2, leave: 2]
    end
  end

  @doc false
  def start_link(module, opts) do
    GenServer.start_link(module, {self(), opts})
  end

  @type robot :: pid
  @type state :: term
  @type opts  :: any
  @type msg   :: Hedwig.Message.t
  @type room  :: binary

  @callback send(pid, msg) :: term
  @callback send_dm(pid, msg) :: term
  @callback send_ephemeral(pid, msg) :: term
  @callback reply(pid, msg) :: term
  @callback direct_reply(pid, msg) :: term
  @callback threaded_reply(pid, msg) :: term
  @callback emote(pid, msg) :: term
  @callback react(pid, msg) :: term
  @callback set_status(pid, msg) :: term
  @callback set_topic(pid, msg) :: term
  @callback join(pid, room) :: term
  @callback leave(pid, room) :: term
end
