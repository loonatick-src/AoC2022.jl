# we buildling a dollar store CHIP-8 interpreter or something of the sort

using DataStructures: Queue, enqueue!, dequeue!
@enum ISA begin
  NOOP = 1
  ADDX = 2
end

import Base.parse

function render_row(screen, r)
  if r > size(screen, 1)
    return nothing
  end
  row = screen[r,:]
  display_row = map(light_up, row)
  for c in display_row
    print(c)
  end
  println()
  nothing
end


struct Instruction
  instr::ISA
  operand::Union{Int, Nothing}

  Instruction(noop) = begin
    if noop == NOOP
      new(NOOP, nothing)
    else
      throw(ArgumentError("ADDX requires an operand"))
    end
  end

  Instruction(addx, operand) = begin
    if addx == ADDX
      new(ADDX, operand)
    else
      throw(ArgumentError("NOOP does not take an argument"))
    end
  end
end

function parse(::Type{Instruction}, s::AbstractString)
  split_input = split_whitespace(s)
  if length(split_input) == 1
    Instruction(NOOP)
  else
    Instruction(ADDX, parse(Int, split_input[2]))
  end
end
  
function solve10_1(s)
  lines = split_newline(s)
  instructions = parse.(Instruction, lines)
  X = 1
  Xs = Vector{Int}()
  probe_values = similar(Xs)
  push!(Xs, X)
  T = 0
  skip_one = false
  for i in instructions
    if i.instr == NOOP
      T += 1
    elseif i.instr == ADDX
      T += 2
      X += i.operand
      push!(Xs, X)
    else
      throw(TypeError("WTF is this? $(i)"))
    end
    
    if length(probe_values) == 6 continue end
    
    if T % 40 == 20
      if i.instr == ADDX
        push!(probe_values, Xs[end-1])
      else
        push!(probe_values, X)
      end
      # need to skip recording T+1 in case next instruction is noop
      skip_one = true
    elseif T % 40 == 21
      if skip_one
        # T-1 has already been probed
        skip_one = false
        continue
      end
      # previous instruction must have been ADDX <operand>
      # X value assumed to be the one before latest add instruction completed
      @show T i
      push!(probe_values, Xs[end-1])
    else
      # for e.g. T = 42, 43 etc
      skip_one = false
    end
  end
  
  T = 20
  sig_strength_sum = 0
  @show probe_values
  for x in probe_values
    sig_strength_sum += T * x
    T += 40
  end
  sig_strength_sum
end

function solve10_2(s)
  lines = split_newline(s)
  instructions = parse.(Instruction, lines)
  N = length(instructions)
  
  nrows = 6
  ncols = 40
  screen = Matrix{UInt8}(undef, nrows, ncols)
  fill!(screen, 0x0)

  X = 1
  idx = 1
  cycle = 1
  
  pending_adds = Queue{Tuple{Int, Int}}()
  r, c = (1, 1)
  pending_add = false
  while r <= nrows && idx <= length(instructions)
    i = instructions[idx]
    idx += 1
    if i.instr == ADDX
      # println("begin executing ADDX $(i.operand)")
      for i in 1:2
        # println("CRT draws pixel at position $(r-1), $(c-1)")
        r,c = draw_pixel!(screen, X, r, c)
        # render_row(screen, r)
      end
      X += i.operand
      # println("Finish executing ADDX $(i.operand). Register is now $(X)")
    else
      # println("Begin executing NOOP")
      # println("CRT draws pixel at position $(r-1), $(c-1)")
      r,c = draw_pixel!(screen, X, r, c)
      # render_row(screen, r)
    end
  end
  render_screen(screen)
end

function draw_pixel!(screen, X, r, c)
  lit = abs(X+1 - c) <= 1
  if lit
    screen[r, c] = 0x2
  else
    screen[r, c] = 0x1
  end
  ncols = size(screen, 2)
  c += 1
  if c > ncols
    c = 1
    r += 1
  end
  (r, c)
end

function light_up(c)
  if c == 0x0
    ' '
  elseif c == 0x1
    '.'
  else
    '#'
  end
end

function render_screen(screen)
  graphical_display = light_up.(screen)
  for row in eachrow(graphical_display)
    for pixel in row
      print(pixel)
    end
    println()
  end
end

