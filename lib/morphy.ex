defmodule Morphy do

  @default_opts [skip_souz: 1, skip_numbers: 1]

  def query(string, opts) do
    s = string
    |>prepare_string

    opts = opts 
           |> Keyword.put(:query, s)
           |> Keyword.put(:handler, 1)
    connect(opts)
  end

  def query(string) do
    query(string, @default_opts)
  end

  def get_id(string) do
    get_id(string, @default_opts)
  end
  def get_id(string, opts) do
    query(string, opts)|>Enum.filter_map(fn (i) -> i end, &mapper/1)
  end

  def wordforms(string) do
    connect([handler: 2, query: string])
  end

  def prepare_string(str) do
      String.downcase(str)
  end

  defp connect(opts) do

    host = Application.get_env(:morphy, :host)
    port = Application.get_env(:morphy, :port)
    
    handler = Keyword.get(opts, :handler)
    q = Keyword.get(opts, :query)
    qlength = byte_size(q)

    sn = Keyword.get(opts, :skip_numbers,0)
    ss = Keyword.get(opts, :skip_souz, 0)

    data = << handler :: unsigned-integer-size(32), sn :: unsigned-integer-size(16), ss :: unsigned-integer-size(16), qlength :: unsigned-integer-size(32), q :: binary >>

    case :gen_tcp.connect(host, port, [:binary, active: false]) do

      {:ok, sock} ->

        # A suitable :buffer is only set if :recbuf is included in
        # :socket_options.
        #
        {:ok, [sndbuf: sndbuf, recbuf: recbuf, buffer: buffer]} =
          :inet.getopts(sock, [:sndbuf, :recbuf, :buffer])

        buffer = buffer
          |> max(sndbuf)
          |> max(recbuf)

        :ok = :inet.setopts(sock, [buffer: buffer])

        :gen_tcp.send(sock, data)

        case :gen_tcp.recv(sock,0) do

          {:ok, resp} -> 
                close(sock)
                Poison.Parser.parse! resp

          {:error, _} -> 

                close(sock)
                []
        end

        {:error, _ } -> []
    end


  end

  defp close(sock), do: :gen_tcp.close(sock)

  defp mapper(x) do
    x["id"]
  end

end
