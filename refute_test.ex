ExUnit.start()

defmodule RefuteTest do

  use ExUnit.Case, async: true

  #refute przykłady
  test "false" do
    refute true == false
  end

  test "odejmowanie" do
    refute 4 - 2 == 42
  end

  test "modul silnia" do
    refute is_float(Silnia.of(2))
  end
end
