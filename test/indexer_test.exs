defmodule Morphy.IndexerTest do

  use ExUnit.Case, async: true

  doctest Morphy.Indexer

  use Morphy.Indexer
  setup context do
    {:ok, morphy} = Morphy.Worker.start_link(context.test)
    {:ok, morphy: morphy}
  end

  test "get index data for storage with options" do

    resp = index("Слон железный продам", [skip_souz: 0, skip_numbers: 0])
    assert resp == [%Morphy.Indexer{id: 698420522, len: 3, weight: 1}, %Morphy.Indexer{id: 3806216619, len: 3, weight: 0.4}, %Morphy.Indexer{len: 3, weight: 0.3, id: 1246083900}]

  end

  test "get index data for storage without options" do

    resp = index("Слон железный")
    assert resp == [%Morphy.Indexer{id: 698420522, weight: 1, len: 2}, %Morphy.Indexer{id: 3806216619, weight: 0.4, len: 2}]

  end

end
