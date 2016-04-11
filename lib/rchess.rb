require 'rchess/version'
require 'matrix'

# enable mutability
class Matrix
  public :"[]=", :set_element, :set_component
end

@turn = 'w'
@board = nil
@w_pieces = %w[♖ ♘ ♗ ♕ ♔ ♙].freeze
@b_pieces = %w[♜ ♞ ♝ ♛ ♚ ♟].freeze

def to_cell rank, file
  return rank.to_i-1, file.ord%97
end

def to_ui rank, file
  return "#{(file+97).chr}#{rank+1}"
end

def reset_game
  # board[0, 0] -> a1
  # board[7, 0] -> a8
  # board[0, 7] -> h1
  # board[7, 7] -> h8
  @board = Matrix[
    '♖♘♗♕♔♗♘♖'.split(''),
    '♙♙♙♙♙♙♙♙'.split(''),
    '        '.split(''),
    '        '.split(''),
    '        '.split(''),
    '        '.split(''),
    '♟♟♟♟♟♟♟♟'.split(''),
    '♜♞♝♛♚♝♞♜'.split('')
  ]
end

def print_game
  puts
  (0..8).reverse_each do |rank|
    row = rank == 0 ? '  ' : "#{rank} "
    ('a'..'h').each do |file|
      c_rank, c_file = to_cell(rank, file)
      row += rank == 0 ? "#{file} " : "#{@board[c_rank, c_file]} "
    end
    puts row
  end
  print "#{@turn}> "
end

def next_move
  gets.split
end

def get_valid_moves(mode, s_move, *arg)
  valid_moves = []
  arg.each do |dir|
    catch :sight do
      (mode == :fixed ? 1..1 : 1..7).each do |dist|
        r_cell = dir.map{ |x| x*dist }
        t_rank = s_move[0] + r_cell[0]
        t_file = s_move[1] + r_cell[1]
        # check bounds
        throw :sight unless [t_rank, t_file].all?{ |t| (0..7).include?(t) }
        t_cell = [t_rank, t_file]
        t_piece = @board[t_rank, t_file]
        debug "thinking about: rel=#{r_cell}, cell=#{t_cell}, piece=#{t_piece}"
        if t_piece == ' '
          # vacant, add
          valid_moves.push(t_cell)
        elsif (@turn == 'w') == (@w_pieces.include?(t_piece))
          # same piece type, cannot add, go to next sight
          throw :sight
        elsif (@turn == 'w') != (@w_pieces.include?(t_piece))
          # different piece type, add, go to next sight
          valid_moves.push(t_cell)
          throw :sight
        end
      end
    end
  end
  valid_moves
end

def is_valid move
  unless move[0] =~ /[a-h][1-8]/ && move[1] =~ /[a-h][1-8]/
    return 'syntax'
  end

  s_rank, s_file = to_cell(move[0][1], move[0][0])
  d_rank, d_file = to_cell(move[1][1], move[1][0])
  piece = @board[s_rank, s_file]

  unless (@turn == 'w' ? @w_pieces : @b_pieces).include?(piece)
    return "not your piece #{piece}"
  end

  s_move = [s_rank, s_file]
  d_move = [d_rank, d_file]
  debug "s_move: #{s_move}, d_move: #{d_move}"
  case piece
  when '♖', '♜'
    valid_moves = get_valid_moves(:look, s_move, [-1, 0], [1, 0], [0, -1], [0, 1])
  when '♝', '♗'
    valid_moves = get_valid_moves(:look, s_move, [-1, -1], [1, -1], [1, 1], [-1, 1])
  when '♞', '♘'
    valid_moves = get_valid_moves(:fixed, s_move, [-2, -1], [-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2])
  when '♛', '♕'
    valid_moves = get_valid_moves(:look, s_move, [-1, -1], [1, -1], [1, 1], [-1, 1], [-1, 0], [1, 0], [0, -1], [0, 1])
  when '♚', '♔'
    valid_moves = get_valid_moves(:fixed, s_move, [-1, -1], [1, -1], [1, 1], [-1, 1], [-1, 0], [1, 0], [0, -1], [0, 1])
    # todo castle
  when '♙'
    valid_moves = get_valid_moves(:fixed, s_move, [1, 0])
    # todo two jump, capture, en passent
  when '♟'
    valid_moves = get_valid_moves(:fixed, s_move, [-1, 0])
  end
  valid_moves.include?(d_move) ? true : "valid moves for #{piece}: #{valid_moves.map{ |move| to_ui(move[0], move[1]) }}"
end

def make_move move
  s_rank, s_file = to_cell(move[0][1], move[0][0])
  d_rank, d_file = to_cell(move[1][1], move[1][0])

  @board[d_rank, d_file] = @board[s_rank, s_file]
  @board[s_rank, s_file] = ' '
  @turn = @turn == 'w' ? 'b' : 'w'
end

def game_over
  # todo
end

def winner
  # todo
end

def debug msg
  # puts msg
end

loop do
  reset_game
  while !game_over
    print_game
    move = next_move
    # todo reset, undo
    if (msg = is_valid(move)).is_a? String
      puts "invalid move. #{msg}"
      next
    end
    make_move(move)
  end
  puts "game over! winner is #{winner}"
end
