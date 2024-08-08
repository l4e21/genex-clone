defmodule Toolbox.Reinsertion do
  alias Types.Chromosome

  #Pure reinsertion is fast, but you could potentially eliminate some of your stronger characteristics in a population as a result.
  def pure(_parents, offspring, _leftovers), do: offspring

  def elitist(parents, offspring, leftovers, survival_rate) do
    parents = parents
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.concat()

    old = parents ++ leftovers
    n = floor(length(old) * survival_rate)
    survivors =
      old
      |> Enum.sort_by(& &1.fitness, &>=/2)
    |> Enum.take(n)
    offspring ++ survivors
  end

  def uniform(parents, offspring, leftover, survival_rate) do
    old = parents ++ leftover
    n = floor(length(old) * survival_rate)
    survivors =
      old
      |> Enum.take_random(n)
    offspring ++ survivors
  end  
  
end

