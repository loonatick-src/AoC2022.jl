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
