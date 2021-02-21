defmodule TreeNode do
  defstruct leaf1: nil,       #First leaf under the node
            leaf2: nil,       #Second leaf under the node
            value: nil,       #Final value in case of a final node
            criteria: nil,    #Criteria to split
            split_value: nil  #List of possible value (associated with leaf1 and leaf2) or mid value to split
end

defmodule DecisionTree do

  def generate_value_lists(list) do
    1..length(list) |> Enum.map(& Combination.combine(list, &1)) |> Enum.concat
  end

  def find_value(%TreeNode{leaf1: leaf1, leaf2: leaf2, value: value, criteria: criteria, split_value: split_value} = _tree, record) do
    cond do
      value                                     -> {:ok, value}
      is_nil(leaf1) and is_nil(leaf2)           -> {:error, "Node for criteria #{to_string criteria} is a dead end"}
      is_nil(record[criteria])                  -> {:error, "Criteria #{to_string criteria} not found in record"}
      is_nil(split_value)                       -> {:error, "Split data for criteria #{to_string criteria} is incomplete"}
      true ->
        cond do
          record.criteria in split_value -> find_value(leaf1, record)
          true -> find_value(leaf2, record)
        end
    end
  end

  def build_decision_tree(dataset, criteria_list) do
    if criteria_list == [] do
      %TreeNode{
        leaf1: nil,
        leaf2: nil,
        value: (if Enum.count(dataset, & &1[:outcome] == :yes) > Enum.count(dataset, & &1[:outcome] == :no), do: :yes, else: :no),
        criteria: nil,
        split_value: nil
      }
    else
      # TODO: ajouter fin d'arbre ici
      current_gini = gini(dataset)
      {%{name: crit_name} = criteria, split_values, crit_gini} = choose_criteria(dataset, criteria_list)
      if current_gini > crit_gini do
        dataset_yes = dataset |> Enum.filter(& &1[crit_name] in split_values)
        dataset_no = dataset |> Enum.filter(& not &1[crit_name] in split_values)
        criteria_left = criteria_list -- [criteria]
        %TreeNode{
          leaf1: build_decision_tree(dataset_yes, criteria_left),
          leaf2: build_decision_tree(dataset_no, criteria_left),
          value: nil,
          split_value: split_values,
          criteria: criteria
        }
      else
        %TreeNode{
          leaf1: nil,
          leaf2: nil,
          value: (if Enum.count(dataset, & &1[:outcome] == :yes) > Enum.count(dataset, & &1[:outcome] == :no), do: :yes, else: :no),
          criteria: nil,
          split_value: nil
        }
      end
    end

  end

  def gini(dataset, outcome_key \\ :outcome, outcome_values \\ [:yes, :no]) do
    ginis = Enum.map(outcome_values, fn v ->
      -:math.pow((Enum.count(dataset, & &1[:outcome] == v) / length(dataset)), 2)
    end) |> Enum.sum
    ginis = 1 - ginis
  end

  #### /!\ for now outcome must be :yes or :no
  def gini_index_discrete(dataset, %{name: crit_name} = criteria, considered_values) do
    dataset_yes = dataset |> Enum.filter(& &1[crit_name] in considered_values)
    dataset_no  = dataset |> Enum.filter(& not &1[crit_name] in considered_values)

    # gini of yes
    gini_yes = gini(dataset_yes)#1 - :math.pow((Enum.count(dataset_yes, & &1[:outcome] == :yes) / length(dataset_yes)), 2) - :math.pow((Enum.count(dataset_yes, & &1[:outcome] == :no) / length(dataset_yes)), 2)

    # gini of no
    gini_no = gini(dataset_no)#1 - :math.pow((Enum.count(dataset_no, & &1[:outcome] == :yes) / length(dataset_no)), 2) - :math.pow((Enum.count(dataset_no, & &1[:outcome] == :no) / length(dataset_no)), 2)

    gini_yes * (length(dataset_yes)/length(dataset)) + gini_no * (length(dataset_no)/length(dataset))

  end

  def choose_criteria(dataset, criteria_list) do
    ginis = criteria_list |> Enum.map(fn c ->
      if c.type == :discrete do
        possible_values = generate_value_lists(c.possible_values)
        |> Enum.map(fn p_v -> {c, p_v, gini_index_discrete(dataset, c, p_v)} end)
      else [] end
    end)
    gini_min = Enum.map(ginis, fn {_,_,v} -> v end) |> Enum.min
    Enum.find(ginis, fn {_,_,v} -> v == gini_min end)
  end



end
