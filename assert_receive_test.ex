ExUnit.start()

defmodule AssertReceiveTest do

  use ExUnit.Case, async: true

  test "receives ping" do
    SendingProcess.run(self())
    assert_received :ping
  end
end


defmodule SendingProcess do
  def run(pid) do
    send(pid, :ping)
  end
end