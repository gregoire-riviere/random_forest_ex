# defmodule RandomForest do

#   @default_training_opts [criteria_sampling: 0.5, keep_test_set?: true, data_sampling: 0.66]

#   def draw(options \\ [] ) do
#     %{color: color, shape: shape} = Enum.into(options, @defaults)
#     IO.puts("Draw a #{color} #{shape}")
#   end

#   def train_forest(dataset, criteria_list, opts // []) do
#     [criteria_sampling: citeria_sampling,
#     keep_test_set?: keep_test_set?,
#     data_sampling: data_sampling] = Enum.into(options, @defaults)

#   end

# end
defmodule RandomForest do

  require Logger

  def build_forest(dataset, criteria_list, data_sample_size, crit_number, tree_number) do
    1..tree_number |> Enum.map(fn _ ->
      sample = 1..data_sample_size |> Enum.map(fn _ ->
        Enum.take_random(dataset, 1)
      end) |> List.flatten
      DecisionTree.build_decision_tree(sample, Enum.take_random(criteria_list, crit_number))
    end)
  end

  def find_value(forest, record) do
    vote = forest |> Enum.map(fn tree ->
      {:ok, r} = DecisionTree.find_value(tree, record)
      r
    end)
    Logger.debug("#{inspect vote}")
    if Enum.count(vote, & &1 == :yes) > Enum.count(vote, & &1 == :no), do: :yes, else: :no
  end

end
