defmodule TreeNode do
  defstruct leaf1: nil,       #First leaf under the node
            leaf2: nil,       #Second leaf under the node
            value: nil,       #Final value in case of a final node
            criteria: nil,    #Criteria to split
            split_value: nil  #List of possible value (associated with leaf1 and leaf2) or mid value to split
end

defmodule Tree do

  def find_value(%TreeNode{leaf1: leaf1, leaf2: leaf2, value: value, criteria: criteria, split_value: split_value, split_type: split_type} = _tree, record) do
    cond do
      value                                     -> {:ok, value}
      is_nil(leaf1) and is_nil(leaf2)           -> {:error, "Node for criteria #{to_string criteria} is a dead end"}
      is_nil(record[criteria])                  -> {:error, "Criteria #{to_string criteria} not found in record"}
      is_nil(split_value)                       -> {:error, "Split data for criteria #{to_string criteria} is incomplete"}
      true ->
        case split_value[record.criteria] do
          :leaf1 -> find_value(leaf1, record)
          :leaf2 -> find_value(leaf2, record)
          nil -> {:error, "Value list #{inspect split_value} incomplete for value #{inspect record.criteria}"}
        end
    end
  end

end
