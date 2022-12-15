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

function simulate_rope(head_pos, tail_pos)
  Δd = head_pos .- tail_pos
  p = prod(Δd)
  s_abs = sum(abs.(Δd))
  if p == 0
    # they are along the same horizontal or vertical
    if s_abs <= 1
      # println("$(head_pos) and $(tail_pos) are touching or have complete overlap")
      # complete overlap or touching
    else
      # println("$(head_pos) and $(tail_pos) are along the same axis but not touching")
      tail_pos = tail_pos .+ clamp_displacement(Δd)
    end
  elseif s_abs <= 2
    # they are touching diagonally
    # println("$(head_pos) and $(tail_pos) are touching diagonally")
  else
    # println("$(head_pos) and $(tail_pos) are not in the same axis, not touching")
    tail_pos = tail_pos .+ clamp_displacement(Δd)
  end
  tail_pos
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
  N = length(knot_positions)
  for k in 1:d
    # move the head
    new_head = knot_positions[1] .+ m
    knot_positions[1] = new_head
    for i in 2:N
      # propagate changes to trailing knots
      h = knot_positions[i-1]
      t = knot_positions[i]
      new_tail = simulate_rope(h, t)
      knot_positions[i] = new_tail
    end
    # @show visualize_knots(knot_positions)
    push!(visited, knot_positions[end])
  end
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
  # visualize(visited)
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

function visualize_knots(knot_positions)
  xs = getindex.(knot_positions, 1)
  ys = getindex.(knot_positions, 2)
  x_min = minimum(xs)
  y_min = minimum(ys)
  x_max = maximum(xs)
  y_max = maximum(ys)
  
  ncols = x_max - x_min + 1
  nrows = y_max - y_min + 1
  board = Matrix{Char}(undef, nrows, ncols)
  fill!(board, '.')
  for (i,xy) in enumerate(knot_positions)
    x, y = xy
    x = x - x_min + 1
    y = y - y_min + 1
    if board[y,x] == '.'
      board[y,x] = string(i)[1]
    end
  end
  board
end
