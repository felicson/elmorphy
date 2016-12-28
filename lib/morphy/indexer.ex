defmodule Morphy.Indexer do
 
  defstruct [:id, :weight, :len]

  @default_opts [skip_souz: 0, skip_numbers: 0]

  def index(string, opts) do
    data = Morphy.query(string, opts)
    len = length(data) 
    data |> Enum.map fn (x) -> gen_struct(x,len) end
  end

  def index(string) do
    index(string, @default_opts)
  end

  defp gen_struct(x,len) do
    %Morphy.Indexer{id: x["id"], weight: x["weight"], len: len}
  end

  defmacro __using__([]) do
    quote do
      import Morphy.Indexer, only: [index: 2, index: 1]
    end
  end

end
