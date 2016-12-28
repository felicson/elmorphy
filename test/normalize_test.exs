defmodule Morphy.NormalizeTest do

  use ExUnit.Case, async: true

  doctest Morphy.Normalize

  setup context do
    {:ok, morphy} = Morphy.Worker.start_link(context.test)
    {:ok, morphy: morphy}
  end

  import Morphy.Normalize

  test "get only uniq wordforms" do

    resp = wordforms("Слон слона")
    assert resp == ["слон", "слона", "слону", "слоном", "слоне", "слоны", "слонов", "слонам", "слонами", "слонах"]
  end

end
