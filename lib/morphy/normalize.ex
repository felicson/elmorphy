defmodule Morphy.Normalize do

  def wordforms(string) do
    Morphy.wordforms(string) |>Enum.uniq
  end

end
