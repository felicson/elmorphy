defmodule Morphy.Normalize do

  def wordforms(string) do
    Morphy.wordforms(string) |>Enum.uniq_by(fn x -> x end)
  end

end
