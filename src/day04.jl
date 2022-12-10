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
