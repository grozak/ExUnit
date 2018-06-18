%%%-------------------------------------------------------------------
%%% @author Grzegorz
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. kwi 2018 17:07
%%%-------------------------------------------------------------------
-module(pollution).
-author("Grzegorz").

%% API
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3, getMinimumPollutionStation/2]).

-record(measurement, {date, type, value}).
-record(station, {name, coords, measurements = []}).

%tworzy i zwraca nowy monitor zanieczyszczeń;
createMonitor() ->
  [].

%dodaje do monitora wpis o nowej stacji pomiarowej (nazwa i współrzędne geograficzne), zwraca zaktualizowany monitor;
addStation(Monitor, Name, {X, Y}) ->
  case (lists:any(fun(#station{name = N}) ->
    N =:= Name end, Monitor)) orelse (lists:any(fun(#station{coords = {X1, Y1}}) ->
    (X1 == X andalso Y1 == Y) end, Monitor)) of
    false -> [#station{name = Name, coords = {X, Y}} | Monitor];
    true -> {error, "Station already exists"}
  end.

%dodaje odczyt ze stacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru, wartość), zwraca zaktualizowany monitor;
addValue(Monitor, {X,Y}, Date, Type, Value) ->
  case lists:any(fun(#station{coords=C, measurements = M}) ->
    C =:= {X,Y} andalso lists:any(fun(#measurement{date = D, type = T}) ->
      {D, T} == {Date, Type} end, M) == false end, Monitor) of
    true -> addV2(Monitor, {X,Y}, Date, Type, Value);
    false -> {error, "Cannot add value"}
  end;
addValue(Monitor, Name, Date, Type, Value) ->
  case lists:any(fun(#station{name = N, measurements = M}) ->
    N =:= Name andalso lists:any(fun(#measurement{date = D, type = T}) ->
      {D, T} == {Date, Type} end, M) == false end, Monitor) of
    true -> addV(Monitor, Name, Date, Type, Value);
    false -> {error, "Cannot add value"}
  end.


%usuwa odczyt ze stacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru), zwraca zaktualizowany monitor;
removeValue(Monitor, Name, Date, Type) ->
  removeV(Monitor, Name, Date, Type).

addV2([H = #station{coords = {X,Y}} | T], {X,Y}, Date, Type, Value) ->
  [#station{name = H#station.name, coords = H#station.coords, measurements = H#station.measurements ++ [#measurement{date = Date, type = Type, value = Value}]} | T];
addV2([H | T], {X,Y}, Date, Type, Value) -> [H | addV(T, {X,Y}, Date, Type, Value)].

addV([H = #station{name = Name} | T], Name, Date, Type, Value) ->
  [#station{name = H#station.name, coords = H#station.coords, measurements = H#station.measurements ++ [#measurement{date = Date, type = Type, value = Value}]} | T];
addV([H | T], Name, Date, Type, Value) -> [H | addV(T, Name, Date, Type, Value)].

removeV([H = #station{name = Name} | T], Name, Date, Type) ->
  NM = lists:filter(fun(#measurement{type = Ty, date = D}) ->
    (Ty /= Type orelse D /= Date) end, H#station.measurements),
  [#station{name = H#station.name, coords = H#station.coords, measurements = NM}];
removeV([H | T], Name, Date, Type) -> [H | removeV(T, Name, Date, Type)];
removeV([H | T], {X, Y}, Date, Type) -> [H | removeV(T, {X, Y}, Date, Type)].

%zwraca wartość pomiaru o zadanym typie, z zadanej daty i stacji;
getOneValue([H = #station{name = Name} | T], Name, Date, Type) ->
  [{_, _, _, Value}] = lists:filter(fun(#measurement{type = Ty, date = D}) ->
    (Ty == Type andalso D == Date) end, H#station.measurements),
  Value;
getOneValue([H | T], Name, Date, Type) -> getOneValue(T, Name, Date, Type).

%zwraca średnią wartość parametru danego typu z zadanej stacji;
getStationMean([H = #station{name = Name} | T], Name, Type) ->
  Values = lists:foldl(fun(X, Sum) -> X + Sum end, 0, [X || {_, _, _, X} <- lists:filter(fun(#measurement{type = Ty}) ->
    Ty == Type end, H#station.measurements)]),
  Length = lists:foldl(fun(X, Len) -> 1 + Len end, 0, [X || {_, _, _, X} <- lists:filter(fun(#measurement{type = Ty}) ->
    Ty == Type end, H#station.measurements)]),
  case Length == 0 of
    true -> 0;
    _ -> Values / Length
  end;
getStationMean([H | T], Name, Type) -> getStationMean(T, Name, Type).

%zwraca średnią wartość parametru danego typu, danego dnia na wszystkich stacjach;
getDailyMean(Monitor, {Date, Time}, Type) ->
  {Sum, Count} = sumDailyMean(Monitor, {Date, Time}, Type, 0, 0),
  Sum / Count.

sumDailyMean([], _, _, Ac, Count) -> {Ac, Count};
sumDailyMean([H | T], {Date, Time}, Type, Ac, Count) ->
  StationValues = lists:foldl(fun(X, Sum) ->
    X + Sum end, 0, [X || {_, _, _, X} <- lists:filter(fun(#measurement{type = Ty, date = {D,T}}) ->
    (Ty == Type andalso D == Date) end, H#station.measurements)]),
  StationCount = lists:foldl(fun(X, Sum) ->
    1 + Sum end, 0, [X || {_, _, _, X} <- lists:filter(fun(#measurement{type = Ty, date = {D,T}}) ->
    (Ty == Type andalso D == Date) end, H#station.measurements)]),
  sumDailyMean(T, {Date, Time}, Type, Ac + StationValues, Count + StationCount).

%wyszukuje stacje z najniższym zanieczyszczeniem danego typu (wylosowane)
getMinimumPollutionStation([H | T], Type) ->
  Min = getStationMean([H], H#station.name, Type),
  case Min > 0 of
    true -> {_, N, C, _} = searchMinimumPollutionStation(T, Type, Min, H);
    false -> {_, N, C, _} = searchMinimumPollutionStation(T, Type, Min, {0, "NoStation", {"-", "-"}, 0})
  end,
  {N, C}.


searchMinimumPollutionStation([], _, _, MinStation) -> MinStation;
searchMinimumPollutionStation([H | T], Type, Min, MinStation) ->
  HMean = getStationMean([H], H#station.name, Type),
  case Min > 0 of
    true -> case (HMean < Min andalso HMean > 0) of
              true -> searchMinimumPollutionStation(T, Type, HMean, H);
              false -> searchMinimumPollutionStation(T, Type, Min, MinStation)
            end;
    false -> case (HMean > 0) of
               false -> searchMinimumPollutionStation(T, Type, HMean, MinStation);
               true -> searchMinimumPollutionStation(T, Type, HMean, H)
             end
  end.


