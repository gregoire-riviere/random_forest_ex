defmodule RandomForest do

  @default_training_opts [criteria_sampling: 0.5, keep_test_set?: true, data_sampling: 0.66]

  def draw(options \\ [] ) do
    %{color: color, shape: shape} = Enum.into(options, @defaults)
    IO.puts("Draw a #{color} #{shape}")
  end

  def train_forest(dataset, criteria_list, opts // []) do
    [criteria_sampling: citeria_sampling,
    keep_test_set?: keep_test_set?,
    data_sampling: data_sampling] = Enum.into(options, @defaults)

  end

end
