defmodule Morphy.NormalizeTest do

  use ExUnit.Case, async: true

  doctest Morphy.Normalize

  import Morphy.Normalize

  test "get only uniq wordforms" do

    resp = wordforms("Слон слона")
    assert resp == ["слон", "слона", "слону", "слоном", "слоне", "слоны", "слонов", "слонам", "слонами", "слонах"]
  end

end
