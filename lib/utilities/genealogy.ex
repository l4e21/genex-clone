defmodule Utilities.Genealogy do
  use GenServer

  def init(_opts) do
    {:ok, Graph.new()}
  end

  def handle_cast({:add_chromosomes, chromosomes}, genealogy) do
    {:noreply, Graph.add_vertices(genealogy, chromosomes)}
  end

  # Child is mutant of Parent
  def handle_cast({:add_chromosome, parent, child}, genealogy) do
    new_genealogy =
      genealogy
      |> Graph.add_edge(parent, child)
    {:noreply, new_genealogy}
  end
  # Child is crossover of Parents
  def handle_cast({:add_chromosome, parent_a, parent_b, child}, genealogy) do
    new_genealogy =
      genealogy
      |> Graph.add_edge(parent_a, child)
      |> Graph.add_edge(parent_b, child)
    {:noreply, new_genealogy}
  end

  def handle_call(:get_tree, _, genealogy) do
    {:reply, genealogy, genealogy}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, _opts, name: __MODULE__)
  end

  def add_chromosomes(chromosomes) do
    GenServer.cast(__MODULE__, {:add_chromosomes, chromosomes})
  end

  def add_chromosome(parent, child) do
    GenServer.cast(__MODULE__, {:add_chromosome, parent, child})
  end

  def add_chromosome(parent_a, parent_b, child) do
    GenServer.cast(__MODULE__, {:add_chromosome, parent_a, parent_b, child})
  end
  
  def get_tree do
    GenServer.call(__MODULE__, :get_tree)
  end

end
