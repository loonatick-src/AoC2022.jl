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

export read_input

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
  sum(elf_capacities[end-1:end])
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
function complete_overlap(x::UnitRange{T}, y::UnitRange{T}) where {T}
  x.start >= y.start && x.stop <= y.stop
end

const ⊂ = complete_overlap


function partial_overlap(x::R, y::R) where {R <: UnitRange}
  x.start <= y.start && x.stop <= y.stop && x.stop >= y.start
end

function overlap(x::R, y::R) where {R <: UnitRange}
  x ⊂ y ||
    y ⊂ x ||
    partial_overlap(x, y) ||
    partial_overlap(y, x)
      
end

const ∧ = overlap

function solve4_1(input_str)
  task_pairs = split(input_str, '\n')
  split_tasks = split.(task_pairs, ',')
  nredundant_tasksets = 0
  for p in split_tasks
    tis = parse_interval.(p)
    if tis[1] ⊂ tis[2] || tis[2] ⊂ tis[1]
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
      nredundant_tasksets +=1
    end
  end
  nredundant_tasksets
end

function parse_interval(s)
  interval_lims = parse.(Int, split(s, '-'))
  interval_lims[1]:interval_lims[2]
end

#== Day 5 ==#
using DataStructures: Stack

function parse_stacks(stack_lines)
  labels = stack_lines[end]
  # assumes no more than 9 stacks really
  offsets = map(x -> x.start, findall(r"[1-9]", labels))
  nstacks = labels |> strip |> split_whitespace |> length
  crate_stacks = Vector{Stack{eltype(labels)}}(undef, nstacks)
  # TODO: there has to be a better way of this initialization
  for i in 1:length(crate_stacks)
    crate_stacks[i] = Stack{eltype(labels)}()
  end
  # TODO: there should be reverse iterator or something like that
  for line in stack_lines[end-1:-1:1]
    crate_labels = line[offsets]
    for (label,stack) in zip(crate_labels, crate_stacks)
      if label != ' '
        push!(stack, label)
      end
    end
  end
  crate_stacks
end

function parse_moves(stacks, proc)
  number_idxs = [2,4,6]
  split_moves = proc .|> split_whitespace
  move_nums = Matrix{Int}(undef, 3, length(proc))
  for (i,move) in enumerate(split_moves)
    move_nums[:,i] .= parse.(Int, move[number_idxs])
  end
  move_nums
end

function time_to_move9001!(stacks, moves)
  for m in eachcol(moves)
    count, from, to = m
    temp = Stack{Char}()
    for i in 1:count
      push!(temp, pop!(stacks[from]))
    end
    for i in 1:count
      push!(stacks[to], pop!(temp))
    end
  end
  nothing
end

function solve5_1(s)
  input_lines = split(s, '\n')
  record_break = findfirst(s->length(s) == 0, input_lines)
  stack_lines = input_lines[1:record_break - 1]
  stacks = parse_stacks(stack_lines)
  proc = input_lines[record_break + 1 : end]
  moves = parse_moves(stacks, proc)
  time_to_move!(stacks, moves)
  top_crates = first.(stacks)
  top_crates
end


function solve5_2(s)
  input_lines = split(s, '\n')
  record_break = findfirst(s->length(s) == 0, input_lines)
  stack_lines = input_lines[1:record_break - 1]
  stacks = parse_stacks(stack_lines)
  proc = input_lines[record_break + 1 : end]
  moves = parse_moves(stacks, proc)
  time_to_move9001!(stacks, moves)
  top_crates = first.(stacks)
  top_crates
end

#== Day 6 ==#
import Base:findfirst

using DataStructures: Deque, popfirst!, pushfirst!

function findfirst(target::T, deq::Deque{T}) where {T}
  for (i,x) in enumerate(deq)
    if x == target
      return i
    end
  end
  return 0
end

function find_marker(s, l)
  char_set = Deque{eltype(s)}()
  rv = 0
  for (i,c) in enumerate(s)
    loc = findfirst(c, char_set)
    if loc == 0
      push!(char_set, c)
      if length(char_set) == l
        return i
      end
    else
      push!(char_set, c)
      for i in 1:loc
        popfirst!(char_set)
      end
    end
  end
  return -1 # unreachable for nice input
end

# refactored this after the fact :/
function solve6_1(s)
  find_marker(s, 4)
end


function solve6_2(s)
  find_marker(s, 14)
end

#== DAY 7 ==#
"""Radical"""
parse_int(s) = parse(Int, s)

@enum CMD begin
  ls
  cd
end

mutable struct DirNode
  children::Vector{Union{Int, DirNode}}
  parent::Union{DirNode, Nothing}
end

parse_filesize(s) = s |> split_whitespace |> first |> parse_int

function parse_cmd(s)
  tokens = split_whitespace(s)
  cmd_name = tokens[2]
  @match cmd_name begin
    "ls" => ls
    "cd" => cd
    _ => ls   # unreachable for nice input and good logic
  end
end

function process_ls!(ds, curr_dir, input_lines, line_number)
  line_number += 1
  while line_number <= length(input_lines)
    line = input_lines[line_number]
    split_line = split_whitespace(line)
    if (split_line[1]) == "dir"
      push!(curr_dir.children, DirNode(Union{Int, DirNode}[], curr_dir))
    elseif split_line[1] != raw"$"
      push!(cur_dir.children, parse_filesize(line))
    else
      return line_number
    end
    line_number += 1
  end
  line_number
end

function process_cd!(ds, curr_dir, line)
  dir_name = split_whitespace(line)[2]
  if dir_name == ".."
    return curr_dir.parent
  else
    push!(curr_dir.children, DirNode(Union{Int,DirNode}[], curr_dir))
    return curr_dir.children[end]
  end
end

function reduce!(ds)
  # TODO
end

function solve7_1(s)
  ds = DirNode(Union{Int, DirNode}[], nothing)
  input_lines = split(s, '\n')
  curr_dir = ds
  line_number = 2
  while line_number < length(input_lines)
    l = input_lines[line_number]
    cmd = parse_cmd(l)
    if cmd == ls
      line_number = process_ls!(ds, curr_dir, input_lines, line_number)
    else
      curr_dir = process_cd!(ds, curr_dir, l)
    end
  end
  ds
end

function solve7_2(s)
end

end  # module AoC2022
