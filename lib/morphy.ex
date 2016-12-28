defmodule Morphy do

  use Application

  @default_opts [skip_souz: 1, skip_numbers: 1]

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
  

    children = [
      worker(Morphy.Worker, [Morphy.Worker]),
    ]

    opts = [strategy: :one_for_one, name: Morphy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def query(string, opts) do
    s = string
        |>prepare_string

    opts = opts 
           |> Keyword.put(:query, s)
           |> Keyword.put(:handler, 1)

    Morphy.Worker.command(Morphy.Worker, opts)
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
    Morphy.Worker.command(Morphy.Worker, [handler: 2, query: string])
  end

  def prepare_string(str) do
    String.downcase(str)
  end

  defp mapper(x) do
    x["id"]
  end
end
