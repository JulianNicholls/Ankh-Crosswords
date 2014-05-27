require 'gridpoint'
require 'cluelist'
require 'traverser'

module Crossword
  # Represent a whole crossword grid
  class Grid
    extend Forwardable

    def_delegators :@cluelist, :clues, :clues_of, :across_clues, :down_clues
    def_delegators :@cluelist, :cell_pos
    def_delegators :@cluelist, :first_clue, :next_clue, :prev_clue
    def_delegators :@traverser, :cell_down, :cell_up, :cell_right, :cell_left
    def_delegators :@traverser, :next_word_cell, :prev_word_cell

    attr_reader :width, :height

    # raw rows come in as an array of strings with one character per cell,
    # '.' for blank

    def initialize( raw_rows, clues )
      @width, @height = raw_rows[0].size, raw_rows.size
      @cluelist       = ClueList.new
      @traverser      = Traverser.new( self )

      build_grid( raw_rows )
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
      gpoint = @cluelist.cell_pos( number, direction )
      word   = [gpoint]

      loop do
        gpoint = @traverser.next_cell( gpoint, direction )
        break if gpoint.nil?
        word << gpoint
      end

      word
    end

    def word_num_from_pos( pos, direction )
      return 0 if cell_at( pos ).blank?

      @cluelist.clues_of( direction ).each do |clue|
        cells = word_cells( clue.number, direction )
        return clue.number if cells.include? pos
      end

      fail "No word from #{pos}"
    end

    def completed
      each_with_position do |cell, _|
        next if cell.blank?
        
        return false  if cell.user == ''
        return :wrong if cell.user != cell.letter
      end

      :complete    # All present and correct
    end

    private

    def build_grid( raw_rows )
      @grid = []

      raw_rows.each { |r| r.each_char { |c| @grid << Cell.new( c ) } }
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

    # Represent one cell in the crossword with its solution letter, user entry,
    # possible number, and highlight state.
    class Cell
      attr_reader :letter, :user, :error
      attr_accessor :number, :highlight

      def initialize( letter )
        @letter = letter
        @user   = ''
        @number = 0
        @highlight = :none
        @error  = false
      end

      def blank?
        @letter == '.'
      end
      
      def user=( ltr )
        @user  = ltr
        @error = user != '' && letter != user
      end
    end
  end
end
