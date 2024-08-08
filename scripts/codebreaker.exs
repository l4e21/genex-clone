defmodule Codebreaker do
  @behaviour Problem
  alias Types.Chromosome
  import Bitwise

  def genotype do
    genes = for _ <- 1..64, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 64}
  end
  
  def fitness_function(chromosome) do
    target = "ILoveGeneticAlgorithms"
    encrypted = "LIjs`B`k`qlfDibjwlqmhv"
    cipher = fn word, key -> Enum.map(word, fn x -> rem(bxor(x, key), 32768) end) end
    key =
      chromosome.genes
      |> Enum.map(& Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)
    guess = List.to_string(cipher.(String.to_charlist(encrypted), key))
    String.jaro_distance(target, guess)
  end

  def terminate?(population, _generation, _temperature), do: Enum.max_by(population, &Codebreaker.fitness_function/1).fitness == 1

  
end

soln = Genetic.run(Codebreaker,
  crossover_type: &Toolbox.Crossover.single_point/2)

{key, ""} =
soln.genes
|> Enum.map(& Integer.to_string(&1))
|> Enum.join("")
|> Integer.parse(2)
IO.write "\nThe Key is #{key}\n"
