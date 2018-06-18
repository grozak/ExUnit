defmodule HelloWorld do
  def print() do
    IO.write("Hello world")
  end
end

ExUnit.start()

defmodule AssertCaptureIOTest do

  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  test "capture io" do
    assert capture_io(fn -> HelloWorld.print() end) == "Hello world"
  end
end


