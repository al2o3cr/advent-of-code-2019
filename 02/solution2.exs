defmodule IntcodeCpu do
  def load_program() do
    IO.read(:stdio, :all)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {a, b} -> {b, a} end)
  end

  def execute(pc, program) do
    instruction = program[pc]
    if instruction == 99 do
      {:stop, pc, program}
    else
      input_1 = program[program[pc+1]]
      input_2 = program[program[pc+2]]
      output = program[pc+3]

      case compute(instruction, input_1, input_2) do
        {:ok, result} ->
          {:continue, pc+4, Map.put(program, output, result)}

        {:error, message} ->
          IO.puts("crashed at PC=#{pc}, error #{message}")
          {:stop, pc, program}
      end
    end
  end

  def compute(1, a, b), do: {:ok, a + b}
  def compute(2, a, b), do: {:ok, a * b}
  def compute(i, _, _), do: {:error, "no such instruction #{i}"}

  def run(program, pc) do
    case execute(pc, program) do
      {:continue, next_pc, next_program} -> run(next_program, next_pc)
      {:stop, final_pc, final_program} -> {final_pc, final_program}
    end
  end

  def dump({pc, program}) do
    IO.inspect(pc, label: "PC")
    dump(program)
  end

  def dump(program) do
    Map.keys(program)
    |> Enum.sort()
    |> Enum.map(&program[&1])
    |> IO.inspect(limit: :infinity)
  end
end

defmodule ResultFinder do
  def evaluate(program, noun, verb) do
    program = Map.put(program, 1, noun) |> Map.put(2, verb)

    {_final_pc, final_program} = IntcodeCpu.run(program, 0)

    final_program[0]
  end

  @possible_nouns 0..99
  @possible_verbs 0..99

  def search(program, target) do
    candidates()
    |> Stream.take_while(fn {n, v} -> evaluate(program, n, v) != target end)
    |> Stream.take(-1)
    |> Enum.to_list()
    |> hd()
  end

  defp candidates do
    @possible_nouns
    |> Stream.flat_map(fn n -> Stream.map(@possible_verbs, fn v -> {n, v} end) end)
  end
end

program = IntcodeCpu.load_program()
program |> ResultFinder.evaluate(12, 2) |> IO.inspect()

# NOTE: result will be the last searched coordinate BEFORE the match
program |> ResultFinder.search(19690720) |> IO.inspect()
