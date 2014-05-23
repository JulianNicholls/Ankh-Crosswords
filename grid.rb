require 'gridpoint'
require 'cluelist'

module Crossword
  # Represent a whole crossword grid
  class Grid
    extend Forwardable

    def_delegators :@cluelist, :across_clues, :down_clues, :first_clue

    attr_reader :width, :height

    def initialize( rows, clues )
      @width, @height = rows[0].size, rows.size
      @cluelist       = ClueList.new

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

    def each_with_position
      height.times do |row|
        width.times { |col| yield cell_at( row, col ), GridPoint.new( row, col ) }
      end
    end

    def word_cells( number, direction )
      gpoint = @cluelist.cell_number( number, direction )
      word   = [gpoint]

      loop do
        gpoint = next_cell( gpoint, direction )
        break if gpoint.nil?
        word << gpoint
      end

      word
    end

    def word_from_pos( pos, direction )
      return [[], 0] if cell_at( pos ).blank?

      @cluelist.clues( direction ).each do |clue|
        cells = word_cells( clue.number, direction )
        return [cells, clue.number] if cells.include? pos
      end

      fail "No word from #{pos}"
    end

    def next_word_cell( state )
      raw_next = next_cell( state.gpos, state.dir )

      state.gpos = raw_next and return unless raw_next.nil?  # same word

      number = @cluelist.next_clue( state.number, state.dir )

      if number == state.number   # End of list, swap directions
        state.swap_direction
        number = first_clue( state.dir )
      end

      state.number = number
      state.gpos   = @cluelist.cell_number( number, state.dir )
    end

    def prev_word_cell( state )
      raw_prev = prev_cell( state.gpos, state.dir )

      state.gpos = raw_prev and return unless raw_prev.nil?  # same word

      number = @cluelist.prev_clue( state.number, state.dir )

      return if number == state.number    # Already at first

      state.number = number
      state.gpos   = @cluelist.cell_number( number, state.dir )

      # Find the end of the previous word

      loop do
        raw_next = next_cell( state.gpos, state.dir )
        break if raw_next.nil?
        state.gpos = raw_next
      end
    end

    private

    def next_cell( gpoint, direction )
      move_cell( gpoint, direction, 1 )
    end

    def prev_cell( gpoint, direction )
      move_cell( gpoint, direction, -1 )
    end

    def move_cell( gpoint, direction, increment )
      fail "Direction: '#{direction}'" unless [:across, :down].include? direction

      gpoint = gpoint.offset( 0, increment ) if direction == :across
      gpoint = gpoint.offset( increment, 0 ) if direction == :down

      return nil if gpoint.out_of_range?( @height, @width ) ||
                    cell_at( gpoint ).blank?

      gpoint
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

        @cluelist.add Clue.new( :across, number, clues.next, gpoint ) if nan
        @cluelist.add Clue.new( :down,   number, clues.next, gpoint ) if ndn

        cell.number = (number += 1) - 1 if nan || ndn
      end
    end

    def needs_across_number?( gpoint )
      (gpoint.col == 0 || cell_at( gpoint.offset( 0, -1 ) ).blank?) &&
      gpoint.col < @width - 1 && !cell_at( gpoint.offset( 0, 1 ) ).blank?
    end

    def needs_down_number?( gpoint )
      (gpoint.row == 0 || cell_at( gpoint.offset( -1, 0 ) ).blank?) &&
      gpoint.row < @height - 1 && !cell_at( gpoint.offset( 1, 0 ) ).blank?
    end
  end

  # Represent one cell in the crossword with its solution letter, user entry,
  # possible number, and highlight state.
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
