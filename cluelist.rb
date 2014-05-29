require 'clue'

module Crossword
  class Grid
    # Hold the lists of clues
    class ClueList
      attr_reader :clues

      def initialize
        @clues = []
      end

      # Add the clue, then find its length and add that on
      def add( clue, grid )
        @clues << clue
        clue.add_length( grid.word_cells( clue.number, clue.direction ).size )
      end

      def across_clues
        @clues.select { |c| c.direction == :across }
      end

      def down_clues
        @clues.select { |c| c.direction == :down }
      end

      def clues_of( direction )
        direction == :across ? across_clues : down_clues
      end

      def first_clue( direction )
        clues_of( direction ).first.number
      end

      def next_clue( start, direction )
        list = clues_of( direction )

        idx = list.index { |clue| clue.number >= start }

        fail "next: idx == nil, start: #{start}, dir: #{direction}" if idx.nil?

        list[[idx + 1, list.size - 1].min].number
      end

      def prev_clue( start, direction )
        list = clues_of( direction )

        idx = list.rindex { |clue| clue.number <= start }

        fail "prev: idx == nil, start: #{start}, dir: #{direction}" if idx.nil?

        list[[idx - 1, 0].max].number
      end

      def cell_pos( num, direction )
        clue  = clues_of( direction ).find { |c| c.number == num }
        return clue.point unless clue.nil?

        fail "Didn't find #{num} #{direction}"
      end
    end
  end
end
