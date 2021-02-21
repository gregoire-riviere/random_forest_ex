dataset = File.read!("test/heart.csv") |> String.split("\r\n") |> Enum.reject(& &1 == "") |> tl() |> Enum.map(fn line ->
  [age, sex, cp, _, _, fbs, _, _, exang, _, slope, ca, _, outcome] = String.split(line, ",")
  %{
    age: age |> Integer.parse |> elem(0),
    sex: sex,
    cp: cp,
    fbs: fbs,
    exang: exang,
    slope: slope,
    ca: ca,
    outcome: outcome == "0" && :no || :yes
  }
end)

continuous_fields = [:age]
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

random_forest = RandomForest.build_forest(training_set, criteria_list, 100, 6, 75)

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
