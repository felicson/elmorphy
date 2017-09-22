defmodule MorphyTest do

  use ExUnit.Case, async: true
  doctest Morphy
  #
  #
  setup context do
    {:ok, morphy} = Morphy.Worker.start_link(context.test)
    {:ok, morphy: morphy}
  end

  test "prepare query" do
    assert "продам слона" == Morphy.prepare_string("Продам слона")
  end

  test "connect with params" do
    resp = Morphy.query("Большой слон", skip_souz: 1, skip_numbers: 1)
    assert resp == [%{"weight" => 0.4, "word" => nil, "id" => 3435371276}, %{"id" => 698420522, "weight" => 1, "word" => nil}]
  end

  test "connect only query" do

    resp = Morphy.query("Большой слон")
    assert resp == [%{"weight" => 0.4, "word" => nil, "id" => 3435371276}, %{"id" => 698420522, "weight" =>1, "word" => nil}]
  end

  test "get wordforms" do
    assert Morphy.wordforms("Слона") == ["слон", "слона", "слону", "слона", "слоном", "слоне", "слоны", "слонов", "слонам", "слонов", "слонами", "слонах"]
  end

  test "check word in wordforms" do

    resp = Morphy.wordforms("Слонов")
    assert Enum.find(resp, fn (w) -> w=="слон" end ) == "слон"
  end

  test "get only words id" do

    resp = Morphy.get_id("Большой слон")
    assert resp == [3435371276, 698420522]
  end

  test "get wrong words id" do

    resp = Morphy.get_id("???")
    assert resp == []
  end

  test "get only words id without souz" do

    resp = Morphy.get_id("Большой слон продаю для 12", skip_souz: 1, skip_numbers: 0)
    assert resp == [3435371276, 698420522, 1330857165]
  end
end
