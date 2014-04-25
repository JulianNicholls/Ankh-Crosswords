# Represent a whole crossword grid
class CrosswordGrid
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

  private

  def build_grid( rows )
    @grid = []

    rows.each { |r| r.each_char { |c| @grid << Cell.new( c ) } }
  end

  Clue = Struct.new( :direction, :number, :text )
  
  def add_numbers_and_clues( clues )
    number = 1

    @height.times do |row|
      @width.times do |col|
        next if cell_at( row, col ).blank?

        nan, ndn = needs_across_number?( row, col ), needs_down_number?( row, col )

        @clues << Clue.new( :across, number, clues.next ) if nan
        @clues << Clue.new( :down,   number, clues.next ) if ndn

        if nan || ndn
          cell_at( row, col ).number = number
          number += 1
        end
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

  # Represent one cell in the crossword with its letter, user entry, and
  # possible number and clue.
  class Cell
    attr_reader :letter
    attr_accessor :user, :number

    def initialize( letter )
      @letter = letter
      @user   = ''
      @number = 0
    end

    def blank?
      @letter == '.'
    end
  end
end
