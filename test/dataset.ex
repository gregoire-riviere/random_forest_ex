dataset = File.read!("test/heart.csv") |> String.split("\r\n") |> Enum.reject(& &1 == "") |> tl() |> Enum.map(fn line ->
  [age, sex, cp, _, _, fbs, _, max_heart_rate, exang, _, slope, ca, _, outcome] = String.split(line, ",")
  %{
    age: age |> Integer.parse |> elem(0),
    sex: sex,
    cp: cp,
    fbs: fbs,
    max_heart_rate: max_heart_rate |> Integer.parse |> elem(0),
    exang: exang,
    slope: slope,
    ca: ca,
    outcome: outcome == "0" && :no || :yes
  }
end)

continuous_fields = [:age, :max_heart_rate]
criteria_list = hd(dataset) |> Enum.map(fn {k, v} ->
  %{
    name: k,
    type:
    (if k in continuous_fields do
      :continuous
    else :discrete end),
    possible_values:
    (if k in continuous_fields do
      []
    else Enum.map(dataset, & &1[k]) |> Enum.uniq end)
  }
end) |> Enum.reject (& &1.name == :outcome)

{training_set, test_set} = Enum.shuffle(dataset) |> Enum.split(200)

random_forest = RandomForest.build_forest(training_set, criteria_list, 50, 4, 1000)

ok_record = Enum.map(test_set, fn rec ->
  response = RandomForest.find_value(random_forest, rec)
  rec.outcome == response
end) |> Enum.filter(& &1) |> length
IO.puts("Nb records in test set : #{length(test_set)}")
IO.puts("Nb records well : #{ok_record}")
IO.puts("Accuracy : #{ok_record/length(test_set)}")

record = hd(test_set)
RandomForest.find_value(random_forest, record)

# 3..6 |> Enum.map(fn param_n ->
#   5..40 |> Eum.map(fn tree_n ->
#     {param_n, tree_n,

#     1..1000 |> Enum.map(fn _ ->

#     end)
#   end)
# end)

file_name="new_model_cad_chf.bert"

dataset = File.read!("test/#{file_name}") |> :erlang.binary_to_term |> Enum.map(fn p ->
  %{
    ema_position: p.ema_200 > p.close && :below || :above,
    cloud_position: cond do
      p.ssa >= p.close && p.ssb <= p.close -> :inside
      p.ssa <= p.close && p.ssb >= p.close -> :inside
      p.ssa <= p.close && p.ssb <= p.close -> :above
      p.ssa >= p.close && p.ssb >= p.close -> :below
    end,
    cloud_color: p.ssa >= p.ssb && :green || :red,
    size_atr: abs(p.close - p.open)/p.atr,
    extension_200: abs(p.close - p.ema_200)/p.atr,
    cross_kj: cond do
      p.close >= p.kj && p.open <= p.kj -> :bullish
      p.close <= p.kj && p.open >= p.kj -> :bearish
      true -> :none
    end
  } |> Map.merge(p)
end) |> Enum.map(fn p ->
  Map.take(p, [:ts, :atr, :outcome, :rsi, :ema_position, :schaff_tc, :cloud_color, :cloud_position, :candle_color, :ema_200_pr_50, :kj_tk, :cross_kj])
end)

reject_field = [:atr, :ts]
continuous_fields = [:rsi, :schaff_tc, :size_atr, :extension]
criteria_list = hd(dataset) |> Enum.reject(fn {k, _} -> k in reject_field end) |> Enum.map(fn {k, _} ->
  %{
    name: k,
    type:
    (if k in continuous_fields do
      :continuous
    else :discrete end),
    possible_values:
    (if k in continuous_fields do
      []
    else (Enum.map(dataset, & &1[k]) |> Enum.uniq) end)
  }
end) |> Enum.reject (& &1.name == :outcome)

# dataset = Enum.drop(dataset, 205)
{training_set, test_set} = Enum.shuffle(dataset) |> Enum.split(2000)
{val_set, test_set} = Enum.shuffle(test_set) |> Enum.split(2000)
random_forest = RandomForest.build_forest(training_set, criteria_list, 750, 4, 1500)

1..200 |> Enum.map(& &1/2)|> Enum.map(fn i ->
  trade_taken = Enum.map(val_set, fn rec ->
    response = RandomForest.find_value(random_forest, rec, i/100)
    {response, rec.outcome}
  end) |> Enum.filter(fn {a, _} -> a == :yes end)
  length(trade_taken)
  accuracy = length(trade_taken) != 0 && (trade_taken |> Enum.count(fn {_, b} -> b == :yes end)) / length(trade_taken) || 0
  IO.puts("Nb trade taken : #{length(trade_taken)}")
  IO.puts("Accuracy : #{accuracy}")
  IO.puts("i : #{i/100}")
end)

trade_taken = Enum.map(test_set, fn rec ->
  response = RandomForest.find_value(random_forest, rec, 0.2)
  {response, rec.outcome}
end) |> Enum.filter(fn {a, _} -> a == :yes end)
