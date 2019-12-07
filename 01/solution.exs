defmodule FuelComputer do
  def basic_fuel_required(n) do
    Integer.floor_div(n, 3) - 2
  end

  def all_fuel_required(n) do
    new_fuel = basic_fuel_required(n)
    if new_fuel > 0 do
      new_fuel + all_fuel_required(new_fuel)
    else
      0
    end
  end
end

File.stream!("input.txt") |> Stream.map(&String.trim/1) |> Stream.map(&String.to_integer/1) |> Stream.map(&FuelComputer.basic_fuel_required/1) |> Enum.sum() 
