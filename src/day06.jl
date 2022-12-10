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
