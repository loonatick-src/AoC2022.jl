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


# NB: modifed part 1 in-place to get part 2
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
