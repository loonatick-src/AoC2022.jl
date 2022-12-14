module AoC2022

using Match
using Match: @match

get_value(::Type{Val{T}}) where {T} = T

macro comptime(expr)
  fn_name = expr.args[1]
  fn_args = expr.args[2:end]
  expr.args[2:end] .= Val.(fn_args)
  eval(expr)
end

export @comptime

@generated function solve(day, part)
  d = get_value(day)
  p = get_value(part)
  solve_fn = Meta.parse("solve$(d)_$(p)")
  input = Meta.parse("read_input($(d))")
  Expr(:call, solve_fn, input)
end

export solve

split_whitespace(s) = split(s, r"\s+")
split_newline(s) = split(s, '\n')

const DATA_DIR = joinpath("..", "..", "data")

function read_input(day::I) where {I <: Integer}
  input_path = joinpath(DATA_DIR,
                        string(day)) * ".txt"
  open(input_path, "r") |> read |> String |> rstrip
end

function read_input_lines(day::I) where {I <: Integer}
  read_input(day) |> split_newline
end

export read_input
export read_input_lines


include("day01.jl")

include("day02.jl")

include("day03.jl")

include("day04.jl")

include("day05.jl")

include("day06.jl")

include("day07.jl")

include("day08.jl")

include("day09.jl")

end  # module AoC2022
