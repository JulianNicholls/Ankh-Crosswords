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

  def each_with_position
    @height.times do |row|
      @width.times do |col|
        yield cell_at( row, col), row, col
      end
    end
  end

  def word_cells( number, direction )
    _, row, col = cell_number( number )
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

    idx = list.index { |clue| clue.number == start }

    list[[idx + 1, list.size - 1].min].number
  end

  private

  def clue_list( direction )
    direction == :across ? across_clues : down_clues
  end

  def cell_number( num )
    each_with_position do |cell, row, col|
      return [cell, row, col] if cell.number == num
    end

    fail "Didn't find cell with number #{num}"
  end

  def next_cell( row, col, direction )
    fail "Direction: '#{direction}'" unless [:across, :down].include? direction

    row += 1 if direction == :down
    col += 1 if direction == :across

    if row == @height || col == @width || cell_at( row, col ).blank?
      [nil, nil]
    else
      [row, col]
    end
  end

  def build_grid( rows )
    @grid = []

    rows.each { |r| r.each_char { |c| @grid << Cell.new( c ) } }
  end

  Clue = Struct.new( :direction, :number, :text, :region )

  def add_numbers_and_clues( clues )
    number = 1

    each_with_position do |cell, row, col|
      next if cell.blank?

      nan, ndn = needs_across_number?( row, col ), needs_down_number?( row, col )

      @clues << Clue.new( :across, number, clues.next ) if nan
      @clues << Clue.new( :down,   number, clues.next ) if ndn

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
end
