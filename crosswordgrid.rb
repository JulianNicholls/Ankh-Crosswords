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

    def cell_at( row, col = nil )
      if row.respond_to? :row
        @grid[row.row * @width + row.col]
      else
        @grid[row * @width + col]
      end
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
          yield cell_at( row, col ), GridPoint.new( row, col )
        end
      end
    end

    def word_cells( number, direction )
      _, gpoint = cell_number( number, direction )
      word = [gpoint]

      loop do
        gpoint = next_cell( gpoint, direction )
        break if gpoint.nil?
        word << gpoint
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

      fail "idx == nil, start: #{start}, dir: #{direction}" if idx.nil?

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
      clue  = clue_list( direction ).find { |c| c.number == num }

      return [cell_at( clue.point ), clue.point] unless clue.nil?

      clue  = other_list( direction ).find { |c| c.number == num }

      gpoint = clue.point

      loop do
        npoint = prev_cell( gpoint, direction )
        break if npoint.nil?
        gpoint = npoint
      end

      [cell_at( gpoint ), gpoint]
    end

    def next_cell( gpoint, direction )
      move_cell( gpoint.dup, direction, 1 )
    end

    def prev_cell( gpoint, direction )
      move_cell( gpoint.dup, direction, -1 )
    end

    def move_cell( gpoint, direction, increment )
      fail "Direction: '#{direction}'" unless [:across, :down].include? direction

      gpoint.col += increment if direction == :across
      gpoint.row += increment if direction == :down

      if gpoint.out_of_range?( @height, @width ) || cell_at( gpoint ).blank?
        nil
      else
        gpoint
      end
    end

    def build_grid( rows )
      @grid = []

      rows.each { |r| r.each_char { |c| @grid << Cell.new( c ) } }
    end

    def add_numbers_and_clues( clues )
      number = 1

      each_with_position do |cell, gpoint|
        next if cell.blank?

        nan, ndn = needs_across_number?( gpoint ), needs_down_number?( gpoint )

        @clues << Clue.new( :across, number, clues.next, gpoint ) if nan
        @clues << Clue.new( :down,   number, clues.next, gpoint ) if ndn

        if nan || ndn
          cell.number = number
          number += 1
        end
      end
    end

    def needs_across_number?( gpoint )
      (gpoint.col == 0 || cell_at( gpoint.row, gpoint.col - 1).blank?) &&
      gpoint.col < @width - 1 && !cell_at( gpoint.row, gpoint.col + 1 ).blank?
    end

    def needs_down_number?( gpoint )
      (gpoint.row == 0 || cell_at( gpoint.row - 1, gpoint.col ).blank?) &&
      gpoint.row < @height - 1 && !cell_at( gpoint.row + 1, gpoint.col ).blank?
    end
  end

  class GridPoint
    attr_accessor :row, :col

    def initialize( row, col )
      @row, @col = row, col
    end

    def out_of_range?( height, width )
      row < 0 || col < 0 ||
      row >= height || col >= width
    end
  end

  # Represent one cell in the crossword with its solution letter, user entry,
  # and possible number.
  class Cell
    attr_reader :letter
    attr_accessor :user, :number, :highlight

    def initialize( letter )
      @letter = letter
      @user   = ''
      @number = 0
      @highlight = :none
    end

    def blank?
      @letter == '.'
    end
  end
end
