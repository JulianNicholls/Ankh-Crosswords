require 'constants'
require 'clue'

module Crossword
  # Represent a whole crossword grid
  class Grid
    attr_reader :grid
    attr_reader :width, :height

    def initialize( rows, clues )
      @width, @height = rows[0].size, rows.size
      @clues    = []

      build_grid( rows )
      add_numbers_and_clues( clues.to_enum )
    end

    def cell_at( row, col )
      @grid[row * @width + col]
    end

    def across_clues
      @clues.select { |c| c.direction == :across }
    end

    def down_clues
      @clues.select { |c| c.direction == :down }
    end

    def each_with_position
      @height.times do |row|
        @width.times do |col|
          yield cell_at( row, col ), row, col
        end
      end
    end

    def word_cells( number, direction )
      _, row, col = cell_number( number, direction )
      word = [[row, col]]

      loop do
        row, col = next_cell( row, col, direction )
        break if row.nil?
        word << [row, col]
      end

      word
    end

    def first_clue( direction )
      list = clue_list( direction )
      list.first.number
    end

    def next_clue( start, direction )
      list = clue_list( direction )

      idx = list.index { |clue| clue.number >= start }

      raise "idx == nil, start: #{start}, dir: #{direction}" if idx.nil?
      
      list[[idx + 1, list.size - 1].min].number
    end

    private

    def clue_list( direction )
      direction == :across ? across_clues : down_clues
    end

    def other_list( direction )
      direction == :down ? across_clues : down_clues
    end

    def cell_number( num, direction )
      clue  = clue_list( direction ).find { |clue| clue.number == num }
      
      return [cell_at( clue.row, clue.col ), clue.row, clue.col] unless clue.nil?

      clue  = other_list( direction ).find { |clue| clue.number == num }

      row, col = clue.row, clue.col
      
      loop do
        nrow, ncol = prev_cell( row, col, direction )
        break if nrow.nil?
        row, col = nrow, ncol
      end 
      
      return [cell_at( row, col ), row, col]      
    end

    def next_cell( row, col, direction )
      move_cell( row, col, direction, 1 )
    end

    def prev_cell( row, col, direction )
      move_cell( row, col, direction, -1 )
    end
    
    def move_cell( row, col, direction, increment )
      fail "Direction: '#{direction}'" unless [:across, :down].include? direction

      row += increment if direction == :down
      col += increment if direction == :across

      if row < 0 || col < 0 || 
         row == @height || col == @width || 
         cell_at( row, col ).blank?
        [nil, nil]
      else
        [row, col]
      end
    end

    def build_grid( rows )
      @grid = []

      rows.each { |r| r.each_char { |c| @grid << Cell.new( c ) } }
    end

    def add_numbers_and_clues( clues )
      number = 1

      each_with_position do |cell, row, col|
        next if cell.blank?

        nan, ndn = needs_across_number?( row, col ), needs_down_number?( row, col )

        @clues << Clue.new( :across, number, clues.next, row, col ) if nan
        @clues << Clue.new( :down,   number, clues.next, row, col ) if ndn

        if nan || ndn
          cell.number = number
          number += 1
        end
      end
    end

    def needs_across_number?( row, col )
      (col == 0 || cell_at( row, col - 1).blank?) &&
      col < @width - 1 && !cell_at( row, col + 1 ).blank?
    end

    def needs_down_number?( row, col )
      (row == 0 || cell_at( row - 1, col ).blank?) &&
      row < @height - 1 && !cell_at( row + 1, col ).blank?
    end
  end

  # Represent one cell in the crossword with its solution letter, user entry,
  # and possible number.
  class Cell
    attr_reader :letter
    attr_accessor :user, :number, :highlighted

    def initialize( letter )
      @letter = letter
      @user   = ''
      @number = 0
      @highlighted = false
    end

    def blank?
      @letter == '.'
    end
  end

  # Have a clue.
  class Clue
    include Constants

    attr_reader   :direction, :number, :text, :row, :col, :region

    def initialize( direction, number, text, row, column, region = nil )
      @direction  = direction
      @number     = number
      @text       = text
      @row, @col  = row, column
      @region     = region
    end

    def draw( game, pos, max_width )
      font = game.font[:clue]

      size  = font.measure( text )
      tlc   = pos

      font.draw( number, pos.x, pos.y, 1, 1, 1, WHITE )

      if size.width > max_width
        draw_wrapped( game, pos, text, (size.width / max_width).ceil )
      else
        draw_simple( game, pos, text )
      end

      @region = Region.new( tlc, Size.new( CLUE_COLUMN_WIDTH, pos.y - tlc.y ) )
    end

    private

    def draw_wrapped( game, pos, text, parts )
      wrap( text, parts ).each do |part|
        draw_simple( game, pos, part )
      end
    end

    def draw_simple( game, pos, text )
      font = game.font[:clue]

      font.draw( text, pos.x + 18, pos.y, 1, 1, 1, WHITE )
      pos.move_by!( 0, font.height )
    end

    def wrap( text, pieces = 2 )
      return [text] if pieces == 1

      pos    = text.size / pieces
      nspace = text.index( ' ', pos )
      pspace = text.rindex( ' ', pos )

      space = (nspace - pos).abs > (pspace - pos).abs ? pspace : nspace

      [text[0...space]] + wrap( text[space + 1..-1], pieces - 1 )
    end
  end
end
