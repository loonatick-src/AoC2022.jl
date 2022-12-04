module AoC2022

using Match: @match
import Base: in

function in(x::UnitRange{T}, y::UnitRange{T}) where {T}
  x.start >= y.start && x.stop <= y.stop
end

function partial_overlap(x::R, y::R) where {R <: UnitRange}
  x.start <= y.start && x.stop <= y.stop && x.stop >= y.start
end

function overlap(x::R, y::R) where {R <: UnitRange}
  x ∈ y ||
    y ∈ x ||
    partial_overlap(x, y) ||
    partial_overlap(y, x)
      
end

const ∧ = overlap

const DATA_DIR = joinpath("..", "..", "data")

function read_input(day::I) where {I <: Integer}
  input_path = joinpath(DATA_DIR,
                        string(day)) * ".txt"
  open(input_path, "r") |> read |> String |> strip
end

#== DAY 1 ==#
function solve1_2(input_str::S) where {S <: AbstractString}
  split_input = split(input_str, '\n')
  elf = 1
  elf_capacities = Vector{Int}()
  record_breaks = findall(s->s=="", split_input)
  nelves = length(record_breaks)-1  # ignoring the last newline
  rb_prev = 1
  for rb in record_breaks
    push!(elf_capacities,
          sum(parse.(Int,
                     split_input[rb_prev:rb-1])))

    rb_prev = rb + 1
  end
  elf_capacities
end


#== DAY 2 ==#

@enum RPSMove begin
  Rock = 0
  Paper = 1
  Scissors = 2
end

function parse_move(c)
  @match c begin
    'A' || 'X' => Rock
    'B' || 'Y' => Paper
    'C' || 'Z' => Scissors
    _ => Rock  # unreachable for nice input
  end
end

function score_move(c)
  Int(parse_move(c)) + 1
end

function score_round(m, c)
  m = parse_move(m)
  cm = @match c begin
    'X' => (-1, 0)
    'Y' => (0, 3)
    'Z' => (1, 6)
    _ => 0  # unreachable for nice input
  end
  my_move = (Int(m) + 3 + cm[1])%3
  cm[2] + my_move + 1
end

function solve2(input_str)
  input_lines = split(input_str, '\n')
  split_lines = split.(input_lines, ' ')
  move_chars = Matrix{Char}(undef, length(input_lines), 2)
  for (i,sl) in enumerate(split_lines)
    for (j,s) in enumerate(sl)
      move_chars[i,j] = s[1]
    end
  end
  total_score = 0 
  for round in eachrow(move_chars)
    total_score += score_round(round...)
  end
  total_score
end

#== DAY3 ==#
function priority(c)
  p = c - 'a' + 1
  if p < 0
    p += 31 + 27
  end
  p
end

function duplicate_priorities(s)
  pivot = length(s)Ã·2
  c1 = Set(s[1:pivot])
  c2 = Set(s[pivot+1:end])
  duplicates = intersect(c1, c2)
  sum(priority.(duplicates))
end

function solve3_1(input_str)
  input_lines = split(input_str, '\n')
  sum(duplicate_priorities.(input_lines))
end

function find_duplicates(s)
  intersect(s...)
end

function solve3_2(input_str)
  input_lines = split(input_str, '\n')
  total_priority = 0
  for i in 1:3:length(input_lines)
    group = input_lines[i:i+2]
    dups = find_duplicates(group)
    total_priority += sum(priority.(dups))
  end
  total_priority
end


#== DAY 4 ==#
function solve4_1(input_str)
  task_pairs = split(input_str, '\n')
  split_tasks = split.(task_pairs, ',')
  nredundant_tasksets = 0
  for p in split_tasks
    tis = parse_interval.(p)
    if tis[1] ∈ tis[2] || tis[2] ∈ tis[1]
      nredundant_tasksets +=1
    end
  end
  nredundant_tasksets
end

"""Same as `sovle4_1`, but ∈ → ∧"""
function solve4_2(input_str)
  task_pairs = split(input_str, '\n')
  split_tasks = split.(task_pairs, ',')
  nredundant_tasksets = 0
  for p in split_tasks
    tis = parse_interval.(p)
    if tis[1] ∧ tis[2]
      @show tis
      nredundant_tasksets +=1
    end
  end
  nredundant_tasksets
end

function parse_interval(s)
  interval_lims = parse.(Int, split(s, '-'))
  interval_lims[1]:interval_lims[2]
end

end  # module AoC2022
