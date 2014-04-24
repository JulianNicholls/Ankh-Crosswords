# Represent a whole crossword grid
class CrosswordGrid
  attr_reader :grid
  attr_reader :width, :height

  def initialize( rows, clues )
    @width, @height = rows[0].size, rows.size
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
    @across_numbers, @down_numbers = [], []
    clue_number = 1
    clue_index  = 0
    
    @height.times do |row|
      @width.times do |col|
        c = cell_at( row, col )
        next if c.blank?

        assigned = false
      
        if needs_across_number?( row, col )
          @across_numbers << clue_number
          c.number = clue_number
          c.add_clue clues[clue_index]
          clue_index += 1 
          assigned = true
          puts "#{row}, #{col} = #{clue_number}A - #{c.clues.first}"
        end
      
        if needs_down_number?( row, col )
          @down_numbers << clue_number
          c.number = clue_number
          c.add_clue clues[clue_index]
          clue_index += 1 
          assigned = true
          puts "#{row}, #{col} = #{clue_number}D - #{c.clues.last}"
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

  # Represent one cell in the crossword
  class Cell
    attr_reader :letter, :clues
    attr_accessor :user, :number

    def initialize( letter )
      @letter = letter
      @user   = ''
      @number = 0
      @clues  = []
    end

    def blank?
      @letter == '.'
    end
    
    def add_clue( clue )
      @clues << clue
    end
  end
end
