# Crossword module
module Crossword
  # Hold the current state: The cell position, and word number and direction
  # that it's a part of.
  CurrentState = Struct.new(:gpos, :number, :dir) do
    def self.from_clue(clue, grid)
      new(
        grid.cell_pos(clue.number, clue.direction),
        clue.number,
        clue.direction
      )
    end

    def swap_direction
      self.dir = dir == :across ? :down : :across
    end

    def new_word(clue_number, pos)
      self.number = clue_number
      self.gpos   = pos
    end
  end
end
