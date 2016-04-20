#!/bin/env ruby
# encoding: utf-8

require 'matrix'
require 'rchess/version'

# enable mutability
class Matrix
  public :"[]=", :set_element, :set_component
end

class Rchess

  attr_reader :board

  def initialize
    @turn = 'w'
    @board = nil
    @w_pieces = %w[♖ ♘ ♗ ♕ ♔ ♙].freeze
    @b_pieces = %w[♜ ♞ ♝ ♛ ♚ ♟].freeze
    @history = []
    reset_game
  end

  def internalize move
    return move[1].to_i-1, move[0].ord%97
  end

  def externalize move
    return "#{(move[1]+97).chr}#{move[0]+1}"
  end

  def get_piece(rank, file)
    @board[rank, file]
  end

  def set_piece(rank, file, piece)
    @board[rank, file] = piece
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
        c_rank, c_file = internalize([file, rank])
        row += rank == 0 ? "#{file} " : "#{get_piece(c_rank, c_file)} "
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
          t_piece = get_piece(t_rank, t_file)
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

  def get_valid_pawn_moves(s_rank, s_file, op)
    valid_moves = []
    # forward
    t_rank, t_file = s_rank.send(op, 1), s_file
    if get_piece(t_rank, t_file) == ' '
      valid_moves.push([t_rank, t_file])
      # forward twice
      t_rank, t_file = s_rank.send(op, 2), s_file
      if get_piece(t_rank, t_file) == ' ' && (op == :+ ? s_rank == 1 : s_rank == 6)
        valid_moves.push([t_rank, t_file])
      end
    end
    # capture
    other_pieces = op == :+ ? @b_pieces : @w_pieces
    [[s_rank.send(op, 1), s_file+1], [s_rank.send(op, 1), s_file-1]].each do |t_cell|
      t_rank, t_file = t_cell[0], t_cell[1]
      if other_pieces.include?(get_piece(t_rank, t_file))
        valid_moves.push([t_rank, t_file])
      end
    end
    #en passant
    #capture piece if this move is chosen.
    [[s_rank, s_file-1], [s_rank, s_file+1]].each do |opponent_cell|
      t_rank, t_file = opponent_cell[0].send(op, 1), opponent_cell[1]
      if get_piece(opponent_cell[0], opponent_cell[1]) == other_pieces[5]
        valid_moves.push([t_rank, t_file]) if @history.last == [[opponent_cell[1], opponent_cell[0].send(op, 2)], [opponent_cell[1], opponent_cell[0]]]
      end
    end
    valid_moves
  end


def is_valid move
  unless move[0] =~ /[a-h][1-8]/ && move[1] =~ /[a-h][1-8]/
    return 'syntax'
  end

  s_rank, s_file = internalize(move[0]) # source
  d_rank, d_file = internalize(move[1]) # destination
  s_move = [s_rank, s_file]
  d_move = [d_rank, d_file]
  piece = get_piece(s_rank, s_file)
  debug "s_move: #{s_move}, d_move: #{d_move}, piece: #{piece}"

  unless (@turn == 'w' ? @w_pieces : @b_pieces).include?(piece)
    return "not your piece '#{piece}'"
  end

  case piece
  when '♖', '♜'
    valid_moves = get_valid_moves(:look, s_move, [-1, 0], [1, 0], [0, -1], [0, 1])
  when '♗', '♝'
    valid_moves = get_valid_moves(:look, s_move, [-1, -1], [1, -1], [1, 1], [-1, 1])
  when '♘', '♞'
    valid_moves = get_valid_moves(:fixed, s_move, [-2, -1], [-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2])
  when '♕', '♛'
    valid_moves = get_valid_moves(:look, s_move, [-1, -1], [1, -1], [1, 1], [-1, 1], [-1, 0], [1, 0], [0, -1], [0, 1])
  when '♔', '♚'
    valid_moves = get_valid_moves(:fixed, s_move, [-1, -1], [1, -1], [1, 1], [-1, 1], [-1, 0], [1, 0], [0, -1], [0, 1])
    # todo castle, check, move into check
  when '♙', '♟'
    valid_moves = get_valid_pawn_moves(s_rank, s_file, piece == '♙' ? :+ : :-)
  end
  valid_moves.include?(d_move) ? true : "valid moves for #{piece}: #{valid_moves.map{ |move| externalize(move) }}"
end


  def is_valid move
    unless move[0] =~ /[a-h][1-8]/ && move[1] =~ /[a-h][1-8]/
      return 'syntax'
    end


    s_rank, s_file = internalize(move[0]) # source
    d_rank, d_file = internalize(move[1]) # destination
    s_move = [s_rank, s_file]
    d_move = [d_rank, d_file]
    piece = get_piece(s_rank, s_file)
    debug "s_move: #{s_move}, d_move: #{d_move}, piece: #{piece}"

    unless (@turn == 'w' ? @w_pieces : @b_pieces).include?(piece)
      return "not your piece '#{piece}'"
    end

    case piece
    when '♖', '♜'
      valid_moves = get_valid_moves(:look, s_move, [-1, 0], [1, 0], [0, -1], [0, 1])
    when '♗', '♝'
      valid_moves = get_valid_moves(:look, s_move, [-1, -1], [1, -1], [1, 1], [-1, 1])
    when '♘', '♞'
      valid_moves = get_valid_moves(:fixed, s_move, [-2, -1], [-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2])
    when '♕', '♛'
      valid_moves = get_valid_moves(:look, s_move, [-1, -1], [1, -1], [1, 1], [-1, 1], [-1, 0], [1, 0], [0, -1], [0, 1])
    when '♔', '♚'
      valid_moves = get_valid_moves(:fixed, s_move, [-1, -1], [1, -1], [1, 1], [-1, 1], [-1, 0], [1, 0], [0, -1], [0, 1])
      # todo castle, check, move into check
    when '♙', '♟'
      valid_moves = get_valid_pawn_moves(s_rank, s_file, piece == '♙' ? :+ : :-)
    end
    valid_moves.include?(d_move) ? true : "valid moves for #{piece}: #{valid_moves.map{ |move| externalize(move) }}"
  end

  def make_move move
    s_rank, s_file = internalize(move[0])
    d_rank, d_file = internalize(move[1])

    set_piece(d_rank, d_file, get_piece(s_rank, s_file))
    set_piece(s_rank, s_file, ' ')
    # promotion, auto-promote to queen
    if '♙' == get_piece(d_rank, d_file) && d_rank == 7
      set_piece(d_rank, d_file, '♕')
    end
    if '♟' == get_piece(d_rank, d_file) && d_rank == 0
      set_piece(d_rank, d_file, '♛')
    end
    @history.push([[s_file, s_rank],[d_file, d_rank]])
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

  def start_game
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
  end

end
