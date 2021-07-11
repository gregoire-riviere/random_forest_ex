# RandForestEx

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rand_forest_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rand_forest_ex, "~> 0.1.0"}
  ]
end
```

## Usage

Before building a forest, you have to specify your criterias (columns of your dataset). A criteria can either be continuous (like a value between 0 and 1) or discrete (:up or :down for eg). In the case of a discrete value, you have to specify the possible values (auto detect not yet implemented)
So a criteria list should look like this:
```elixir
[
  %{
    name: :slope,
    type: :discrete,
    possible_values: [:up, :down]
  },
 %{
    name: :probability,
    type: :continuous
  }
]
```
You can then easily build a forest by using

```elixir
  RandomForest.build_forest(dataset, criteria_list, data_sample_size, criteria_number, tree_number)
```
* _data_sample_size_ is the number of record taken to build 1 tree
* _criteria_number_ is the number of criteria taken to build 1 tree
* _tree_number_ is the number of tree in the forest

To evaluate a new record through the built forest, you have to use :
```elixir
  RandomForest.find_value(random_forest, rec, threshold)
```
The threshold is the portion of tree that have to agree to end up with a `yes`. Default to 50% (0.5)