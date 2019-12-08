defmodule IntcodeCpu do
  defmodule Decoder do
    def instruction(program, pc) do
      word = program[pc]
      case base_instruction(word) do
        {:zero_arg, opcode} -> {opcode, 1}
        {:one_arg, opcode} -> {opcode, 2, operand(program, pc, :first)}
        {:three_arg, opcode} -> {opcode, 4, operand(program, pc, :first), operand(program, pc, :second), operand(program, pc, :result) }
        _ ->
          IO.puts("Decode error at #{pc}")
          IntcodeCpu.dump(program)
      end
    end

    defp base_instruction(insn) do
      case Integer.mod(insn, 100) do
        99 ->
          {:zero_arg, :stop}
        1 ->
          {:three_arg, :add}
        2 ->
          {:three_arg, :mul}
        3 ->
          {:one_arg, :input}
        4 ->
          {:one_arg, :output}
        _ ->
          IO.puts("Unexpected opcode #{insn}")
      end
    end

    defp operand(program, pc, select) do
      insn = program[pc]
      value = program[pc + operand_offset(insn, select)]
      case operand_mode(insn, select) do
        0 ->
          {:loc, value}
        1 ->
          {:imm, value}
        unknown ->
          IO.puts("Unknown operand mode #{unknown} at #{pc} #{select}")
      end
    end

    defp operand_offset(_insn, :first), do: 1
    defp operand_offset(_insn, :second), do: 2
    defp operand_offset(_insn, :result), do: 3

    defp operand_mode(insn, :first), do: digit(insn, 100)
    defp operand_mode(insn, :second), do: digit(insn, 1000)
    defp operand_mode(insn, :result), do: digit(insn, 10000)

    defp digit(n, offset) do
      n
      |> Integer.floor_div(offset)
      |> Integer.mod(10)
    end
  end

  defmodule Executor do
    def execute(program, pc, {:stop, pc_offset}) do
      {:stop, pc + pc_offset, program}
    end

    def execute(program, pc, {:add, pc_offset, op1, op2, result}) do
      v1 = fetch(program, op1)
      v2 = fetch(program, op2)
      new_program = store(program, result, v1+v2)
      {:continue, pc + pc_offset, new_program}
    end

    def execute(program, pc, {:mul, pc_offset, op1, op2, result}) do
      v1 = fetch(program, op1)
      v2 = fetch(program, op2)
      new_program = store(program, result, v1*v2)
      {:continue, pc + pc_offset, new_program}
    end

    def execute(program, pc, {:input, pc_offset, result}) do
      v1 = IO.read(:stdio, :line) |> String.trim() |> String.to_integer()
      new_program = store(program, result, v1)
      {:continue, pc + pc_offset, new_program}
    end

    def execute(program, pc, {:output, pc_offset, op1}) do
      v1 = fetch(program, op1)
      IO.puts(v1)
      {:continue, pc + pc_offset, program}
    end

    defp fetch(_program, {:imm, value}), do: value
    defp fetch(program, {:loc, value}), do: program[value]

    defp store(program, {:loc, target}, value), do: Map.put(program, target, value)
    defp store(program, {:imm, target}, value) do
      IO.puts("attempt to write to immediate #{target} with #{value}")
      program
    end
  end

  def load_program() do
    File.read!("input.txt")
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {a, b} -> {b, a} end)
  end

  def run(program, pc) do
    insn = Decoder.instruction(program, pc)
    case Executor.execute(program, pc, insn) do
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

program = IntcodeCpu.load_program()
program |> IntcodeCpu.run(0) |> IntcodeCpu.dump()
