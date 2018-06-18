ExUnit.start()

defmodule AssertTest do

  use ExUnit.Case, async: true

  #assert przykłady
  test "truth" do
    assert true
  end

  test "add" do
    assert 2 + 2 == 4
  end

  #test modułu Silnia
  test "modul silnia" do
    assert Silnia.of(0) == 1
    assert Silnia.of(5) == 120
    assert is_integer(Silnia.of(2))
  end

end
