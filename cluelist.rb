require 'clue'

module Crossword
  # Hold the lists of clues
  class ClueList
    def initialize
      @clues = []
    end

    def add( clue )
      @clues << clue
    end

    def across_clues
      @clues.select { |c| c.direction == :across }
    end

    def down_clues
      @clues.select { |c| c.direction == :down }
    end

    def clue_list( direction )
      direction == :across ? across_clues : down_clues
    end

    def other_list( direction )
      direction == :down ? across_clues : down_clues
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

    def prev_clue( start, direction )
      list = clue_list( direction )

      idx = list.rindex { |clue| clue.number <= start }

      fail "idx == nil, start: #{start}, dir: #{direction}" if idx.nil?

      list[[idx - 1, 0].max].number
    end

    def cell_number( num, direction )
      clue  = clue_list( direction ).find { |c| c.number == num }
      return clue.point unless clue.nil?

      fail "Didn't find #{num} #{direction}"
    end
  end
end
