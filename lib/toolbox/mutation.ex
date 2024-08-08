defmodule Toolbox.Mutation do
  alias Types.Chromosome
  import Bitwise

  def flip(chromosome, p) do
    genes =
      chromosome.genes
      |> Enum.map(fn g ->
      if :rand.uniform() < p do
        bxor(g, 1)
      else
        g
      end
    end)
      
    %Chromosome{genes: genes, size: chromosome.size}
  end

  def scramble(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()
    %Chromosome{genes: genes, size: chromosome.size}
  end
  
  def gaussian(chromosome) do
    mu = Enum.sum(chromosome.genes) / length(chromosome.genes)
    sigma =
      chromosome.genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()
      |> Kernel./(length(chromosome.genes))
    genes =
      chromosome.genes
      |> Enum.map(fn _ ->
      :rand.normal(mu, sigma)
    end)
      %Chromosome{genes: genes, size: chromosome.size}
  end

end
