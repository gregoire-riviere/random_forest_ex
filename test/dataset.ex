dataset = File.read!("test/heart.csv") |> String.split("\r\n") |> Enum.reject(& &1 == "") |> tl() |> Enum.map(fn line ->
  [_age, sex, cp, _, _, fbs, _, _, exang, _, slope, ca, _, outcome] = String.split(line, ",")
  %{
    sex: sex,
    cp: cp,
    fbs: fbs,
    exang: exang,
    slope: slope,
    ca: ca,
    outcome: outcome == "0" && :no || :yes
  }
end)

criteria_list = hd(dataset) |> Enum.map(fn {k, v} ->
  %{
    name: k,
    type: :discrete,
    possible_values: Enum.map(dataset, & &1[k]) |> Enum.uniq
  }
end) |> Enum.reject (& &1.name == :outcome)

{training_set, test_set} = Enum.shuffle(dataset) |> Enum.split(200)

# decision_tree = DecisionTree.build_decision_tree(training_set, criteria_list)

# record = hd(test_set)

# ok_record = Enum.map(training_set, fn rec ->
#   {:ok, response} = DecisionTree.find_value(decision_tree, record)
#   rec.outcome == response
# end) |> Enum.filter(& &1) |> length
# IO.puts("Nb records in test set : #{length(test_set)}")
# IO.puts("Nb records well : #{ok_record}")

random_forest = RandomForest.build_forest(training_set, criteria_list, 100, 5, 10)

ok_record = Enum.map(test_set, fn rec ->
  response = RandomForest.find_value(random_forest, rec)
  rec.outcome == response
end) |> Enum.filter(& &1) |> length
IO.puts("Nb records in test set : #{length(test_set)}")
IO.puts("Nb records well : #{ok_record}")
IO.puts("Accuracy : #{ok_record/length(test_set)}")

record = hd(test_set)
RandomForest.find_value(random_forest, record)
