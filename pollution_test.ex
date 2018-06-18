ExUnit.start()

  defmodule PollutionTest do

    use ExUnit.Case, async: true

    setup do
      m = :pollution.createMonitor()
      m = :pollution.addStation(m, "Okocim", {10.18, 20})
      m = :pollution.addValue(m, "Okocim", {{2017, 01, 13}, {10, 21, 30}}, "typ1", 105)
      m = :pollution.addValue(m, "Okocim", {{2017, 01, 14}, {10, 20, 30}}, "typ1", 105)
      m = :pollution.addValue(m, "Okocim", {{2017, 01, 13}, {10, 20, 30}}, "typ2", 10)
      m = :pollution.addStation(m, "Krakow", {70, 80})
      m = :pollution.addValue(m, "Krakow", {{2017, 01, 13}, {10, 20, 30}}, "typ1", 35000000)
      m = :pollution.addValue(m, "Krakow", {{2017, 01, 13}, {10, 20, 30}}, "typ2", 100)
      [m: m]
    end

    test "getMinimumPollutionStation", state do
      assert :pollution.getMinimumPollutionStation(state[:m], "typ1") == {"Okocim", {10.18, 20}}
    end

    test "getDailyMean", state do
      assert :pollution.getDailyMean(state[:m], {{2017, 01, 13}, {0,0}}, "typ2") == 55
    end
  end


