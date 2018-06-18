ExUnit.start()

defmodule AssertRaiseTest do

  use ExUnit.Case, async: true

  test "raise exception" do
    assert_raise ArithmeticError, fn ->
      1/0
    end
  end

end