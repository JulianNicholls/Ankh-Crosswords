# Represent a whole crossword grid
class CrosswordGrid
  attr_reader :grid, :across_clues, :down_clues
  attr_reader :width, :height

  def initialize( rows, clues )
    @width, @height = rows[0].size, rows.size
    @across_clues, @down_clues = [], []

    build_grid( rows )
    add_numbers_and_clues( clues )
  end

  def cell_at( row, col )
    @grid[row * @width + col]
  end

  private

  def build_grid( rows )
    @grid = []

    rows.each { |r| r.each_char { |c| @grid << Cell.new( c ) } }
  end
  
  def add_numbers_and_clues( clues )
    clue_number = 1
    clue_index  = 0
    
    @height.times do |row|
      @width.times do |col|
        c = cell_at( row, col )
        next if c.blank?

        assigned = false
      
        if needs_across_number?( row, col )
          @across_clues << Clue.new( clue_number, clues[clue_index] )
          c.number = clue_number
          clue_index += 1 
          assigned = true
          printf( "%2d, %2d %2dA - %s\n", row, col, clue_number, @across_clues.last.text )
        end
      
        if needs_down_number?( row, col )
          @down_clues << Clue.new( clue_number, clues[clue_index] )
          c.number = clue_number
          clue_index += 1 
          assigned = true
          printf( "%2d, %2d %2dD - %s\n", row, col, clue_number, @down_clues.last.text )
        end
      
        clue_number += 1 if assigned
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
  
  class Clue
    attr_reader :number, :text
    
    def initialize( number, text )
      @number, @text = number, text
    end
  end
end
