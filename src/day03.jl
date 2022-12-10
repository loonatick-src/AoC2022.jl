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
