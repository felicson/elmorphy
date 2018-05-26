defmodule Morphy.Worker do

  use GenServer

  @initial_state %{queue: :queue.new(), socket: nil, host: nil, port: nil}

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(_state) do

    host = Application.get_env(:morphy, :host)
    port = Application.get_env(:morphy, :port)

    {:ok, %{@initial_state | host: host, port: port}}

  end

  def command(pid, opts) do
    GenServer.call(pid, {:command, opts})
  end

  def handle_call({:command, opts}, from, %{queue: queue} = state) do

    handler = Keyword.get(opts, :handler)
    q = Keyword.get(opts, :query)
    qlength = byte_size(q)

    sn = Keyword.get(opts, :skip_numbers,0)
    ss = Keyword.get(opts, :skip_souz, 0)

    data = << handler :: unsigned-integer-size(32), sn :: unsigned-integer-size(16), ss :: unsigned-integer-size(16), qlength :: unsigned-integer-size(32), q :: binary >>

    case :gen_tcp.connect(state.host, state.port, [:binary, active: true, recbuf: 16384]) do

      {:ok, socket} ->

          :ok = :gen_tcp.send(socket, data)

          {:noreply, %{state | queue: :queue.in(from, queue), socket: socket}}

      {:error, _} ->
        {:reply, [], state}
      end
  end

   def handle_info({:tcp, _socket, resp}, %{socket: socket} = state) do
    :inet.setopts(socket, active: :once)
    # We dequeue the next client
    {{:value, client}, new_queue} = :queue.out(state.queue)

    # We can finally reply to the right client.
    GenServer.reply(client, Poison.Parser.parse!(resp))

    {:noreply, %{state | queue: new_queue}}
   end

   def handle_info(:timeout, state) do
      {:noreply, state, 2000}
   end

   def handle_info(_, state), do: {:noreply, state} #handle all unmatched responses
end
