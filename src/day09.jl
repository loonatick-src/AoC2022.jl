using StaticArrays: @SVector

#= TODO: SIMD Vectors might be a better idea.
check the out codegen for pathologies =#

function parse_rope_move(s)
  move, dist = split_whitespace(s)
  d = parse(Int, dist)
  m = @match move begin
    "D" => @SVector[0, -1]
    "U" => @SVector[0, 1]
    "L" => @SVector[-1, 0]
    "R" => @SVector[1, 0]
    _ => @SVector [0, 0] # unreachable for nice input
  end
  (m, d)
end

clamp_unit_box(x) = clamp(x, -1:1)

clamp_displacement(d) = clamp_unit_box.(d)

function simulate_rope(head_pos, tail_pos, m)
  head_pos = head_pos .+ m
  Δd = head_pos .- tail_pos
  p = prod(Δd)
  s = sum(Δd)
  if Δd[1] == Δd[2] == 0
    (head_pos, tail_pos)
  elseif abs.(Δd) == @SVector [1, 1]
    (head_pos, tail_pos)
  elseif sum(abs.(Δd)) == 1
    (head_pos, tail_pos)
  elseif p == 0
    # head and tail are in the same line
    tail_pos = tail_pos .+ m
    (head_pos, tail_pos)
  elseif sum(abs.(Δd)) == 1
    (head_pos, tail_pos)
  else
    tail_pos = tail_pos .+ clamp_displacement(Δd)
    (head_pos, tail_pos)
  end
end


function simulate_rope!(visited, head_pos, tail_pos, m, d)
  for i in 1:d
    head_pos = head_pos .+ m
    Δd = head_pos .- tail_pos
    p = prod(Δd)
    s = sum(Δd)
    if Δd[1] == Δd[2] == 0
      continue
    elseif abs.(Δd) == @SVector [1, 1]
      continue
    elseif sum(abs.(Δd)) == 1
      continue
    elseif p == 0
      # head and tail are in the same line
      tail_pos = tail_pos .+ m
    elseif sum(abs.(Δd)) == 1
      continue
    else
      tail_pos = tail_pos .+ clamp_displacement(Δd)
    end
    push!(visited, tail_pos)
  end
  (head_pos, tail_pos)
end



function solve9_1(s)
  input_lines = split_newline(s)
  moves = parse_rope_move.(input_lines)
  tail_pos = @SVector [1, 1]
  head_pos = @SVector [1, 1]
  visited = Set{typeof(tail_pos)}()
  push!(visited, tail_pos)
  for (m, d) in moves
    (head_pos, tail_pos) = simulate_rope!(visited, head_pos, tail_pos, m, d)
  end
  length(visited)
end

function simulate_longer_rope!(visited, knot_positions, m, d)
  for k in 1:d
    for (i, p) in enumerate(knot_positions[begin:end-1])
      head_pos = p
      tail_pos = knot_positions[i+1]
      head_pos, tail_pos = simulate_rope(head_pos, tail_pos, m)
      knot_positions[i] = head_pos
      knot_positions[i+1] = tail_pos
    end
    push!(visited, knot_positions[end])
  end
end

function longer_rope_step!(visited, knot_positions, m, k, d)
  
end

function solve9_2(s)
  input_lines = split_newline(s)
  moves = parse_rope_move.(input_lines)
  head_pos = @SVector[1,1]
  knot_positions = Vector{typeof(head_pos)}(undef, 10)
  fill!(knot_positions, head_pos)
  visited = Set{typeof(head_pos)}()
  push!(visited, head_pos)
  for (m, d) in moves
    simulate_longer_rope!(visited, knot_positions, m, d)
  end
  length(visited)
end

function visualize(visited)
  T = eltype(eltype(visited))
  min_x = min_y = typemax(T)
  max_x = max_y = typemin(T)
  for xy in visited
    x, y = xy
    min_x = min(min_x, x)
    max_x = max(max_x, x)
    min_y = min(min_y, y)
    max_y = max(max_y, y)
  end
  dims = (max_x - min_x+1, max_y - min_y+1)
  @show dims
  board = Matrix{Char}(undef, dims...)
  fill!(board, '.')
  for xy in visited
    x, y = xy
    x = x - min_x + 1
    y = y - min_y + 1
    board[x,y] = '#'
  end
  board
end
