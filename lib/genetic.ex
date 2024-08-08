defmodule Genetic do
  @moduledoc """
  Documentation for `Genetic`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Genetic.hello()
      :world

  """

  alias Types.Chromosome

  def initialise(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    population = for _ <- 1..population_size, do: genotype.()
    Utilities.Genealogy.add_chromosomes(population)
    population
  end
  

  def evaluate(population, fitness_function, opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
      end
      )
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  def statistics(population, generation, last_max_fitness, temperature, opts \\ []) do
    default_stats = [
      min_fitness: &Enum.min_by(&1, fn c -> c.fitness end).fitness,
      max_fitness: &Enum.max_by(&1, fn c -> c.fitness end).fitness,
      mean_fitness: &Enum.sum(Enum.map(&1, fn c -> c.fitness end))
    ]
    stats = Keyword.get(opts, :statistics, default_stats)
    stats_map =
      stats
      |> Enum.reduce(%{},
      fn {key, func}, acc ->
        Map.put(acc, key, func.(population))
    end
    )
      Utilities.Statistics.insert(generation, stats_map)
  end
  
  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, &Toolbox.Selection.elite/2)
    select_rate = Keyword.get(opts, :selection_rate, 0.8)
    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n+1
    parents =  select_fn
    |> apply([population, n])
    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(& List.to_tuple(&1))
    {parents, MapSet.to_list(leftover)}
    
  end
  

  def crossover(population, opts \\ []) do
    crossover_fn = Keyword.get(opts, :crossover_type, &Toolbox.Crossover.single_point/2)
    
    population
    |> Enum.reduce([], fn {p1, p2}, acc ->
      {c1, c2} = apply(crossover_fn, [p1, p2])
      Utilities.Genealogy.add_chromosome(p1, p2, c1)
      Utilities.Genealogy.add_chromosome(p1, p2, c2)
      [c1, c2 | acc]
    end
    )
  end
  

  def mutation(population, opts \\ []) do
    mutate_fn = Keyword.get(opts, :mutation_type, &Toolbox.Mutation.scramble/1)
    rate = Keyword.get(opts, :mutation_rate, 0.05)
    n = floor(length(population) * rate)
    population
    |> Enum.take(n)
    |> Enum.map(fn c ->
      mutant = apply(mutate_fn, [c])
      Utilities.Genealogy.add_chromosome(c, mutant)
      mutant
    end
    )
  end

  def reinsertion(parents, offspring, leftover, opts \\ []) do
    strategy = Keyword.get(opts, :reinsertion_strategy, &Toolbox.Reinsertion.pure/3)
    apply(strategy, [parents, offspring, leftover])
  end

  def evolve(population, problem, generation, last_max_fitness, temperature, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)

    statistics(population, generation, last_max_fitness, temperature, opts)
    
    best = Enum.max_by(population, &problem.fitness_function/1)
    best_fitness = best.fitness
    fit_str = best_fitness |> :erlang.float_to_binary(decimals: 4)
    temperature = 0.8 * (temperature + (best_fitness - last_max_fitness))
    
    IO.puts("\rCurrent Generation: #{generation}")
    IO.puts("\rCurrent Best: #{best.fitness}")
    IO.puts("\rCurrent temperature: #{temperature}")

    if problem.terminate?(population, generation, temperature) do
      best
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      mutants = mutation(population, opts)
      offspring = children ++ mutants
      new_population = reinsertion(parents, offspring, leftover, opts)
      evolve(new_population, problem, generation + 1, best_fitness, temperature, opts)
    end    
  end

  
  def run(problem, opts \\ []) do
    population = initialise(&problem.genotype/0, opts)
    evolve(population, problem, 0, 0, 0, opts)
  end
  
end
