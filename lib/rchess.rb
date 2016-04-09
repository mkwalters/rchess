require "rchess/version"

@turn = 'w'
@board = {}

def to_cell pos
  return pos[1].to_i-1, pos[0].ord%97
end

def reset_game
  # board[0][0] -> a1
  # board[7][0] -> a8
  # board[0][7] -> h1
  # board[7][7] -> h8
  @board = [
    '♜♞♝♛♚♝♞♜'.split(''),
    '♟♟♟♟♟♟♟♟'.split(''),
    '        '.split(''),
    '        '.split(''),
    '        '.split(''),
    '        '.split(''),
    '♙♙♙♙♙♙♙♙'.split(''),
    '♖♘♗♕♔♗♘♖'.split('')
  ]
end

def print_game
  puts
  (0..8).reverse_each do |rank|
    row = rank == 0 ? '  ' : "#{rank} "
    ('a'..'h').each do |file|
      c_rank, c_file = to_cell([file, rank])
      row += rank == 0 ? "#{file} " : "#{@board[c_rank][c_file]} "
    end
    puts row
  end
  print "#{@turn}> "
end

def next_move
  gets.split
end

@w_pieces = %w[♜ ♞ ♝ ♛ ♚ ♟]
@b_pieces = %w[♖ ♘ ♗ ♕ ♔ ♙]

def is_valid move
  return 'syntax' unless move[0] =~ /[a-h][1-8]/ && move[1] =~ /[a-h][1-8]/

  s_rank, s_file = to_cell(move[0])
  d_rank, d_file = to_cell(move[1])

  return 'not your piece' unless (@turn == 'w' ? @w_pieces : @b_pieces).include?(@board[s_rank][s_file])

  # piece movement (incl capture, en passent)
  # line of sight
  return true
end

def make_move move
  s_rank, s_file = to_cell(move[0])
  d_rank, d_file = to_cell(move[1])

  @board[d_rank][d_file] = @board[s_rank][s_file]
  @board[s_rank][s_file] = ' '
  @turn = @turn == 'w' ? 'b' : 'w'
end

def game_over
  #
end

def winner
  #
end

loop do
  reset_game
  while !game_over
    print_game
    move = next_move
    if (msg = is_valid(move)).is_a? String
      puts "invalid move: #{msg}"
      next
    end
    make_move(move)
  end
  puts "game over! winner is #{winner}"
end
