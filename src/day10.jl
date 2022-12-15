# we buildling a dollar store CHIP-8 interpreter or something of the sort
@enum ISA begin
  NOOP = 1
  ADDX = 2
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
  #= FIXME: the last probed signal value is incorrect for the test input
  #         Not sure why. =#
  
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
