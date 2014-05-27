module Crossword
  class Grid
    # Traverse across the grid, firstly, by word, moving to the next at each end,
    # and secondly, by cell, skipping blank cells.
    class Traverser < Struct.new( :grid )
      # Work out the next word cell, which could be at the beginning of the next
      # word in the same direction, or even the first word in the other direction.
      def next_word_cell( state )
        raw_next = next_cell( state.gpos, state.dir )

        return state.gpos = raw_next unless raw_next.nil?  # same word

        number = grid.next_clue( state.number, state.dir )

        if number == state.number   # End of list, swap directions
          state.swap_direction
          number = grid.first_clue( state.dir )
        end

        state.new_word( number, grid.cell_pos( number, state.dir ) )
      end

      # Work out the previous word cell, which could be the end of the previous word
      # Stops at the first word in the same direction
      def prev_word_cell( state )
        raw_prev = prev_cell( state.gpos, state.dir )

        return state.gpos = raw_prev unless raw_prev.nil?  # same word

        number = grid.prev_clue( state.number, state.dir )

        return if number == state.number    # Already at first

        state.new_word( number, grid.cell_pos( number, state.dir ) )

        # Find the end of the previous word

        loop do
          raw_next = next_cell( state.gpos, state.dir )
          break if raw_next.nil?
          state.gpos = raw_next
        end
      end

      # Move to the next non-blank cell in each of the four directions, stopping
      # at the edges
      def cell_down( gpoint )
        move_cursor( gpoint, 1, 0 )
      end

      def cell_up( gpoint )
        move_cursor( gpoint, -1, 0 )
      end

      def cell_right( gpoint )
        move_cursor( gpoint, 0, 1 )
      end

      def cell_left( gpoint )
        move_cursor( gpoint, 0, -1 )
      end

      # Move to the next and previous cell in the specified direction,
      # returning it or nil if blank or off the grid
      def next_cell( gpoint, direction )
        move_cell( gpoint, direction, 1 )
      end

      private

      def prev_cell( gpoint, direction )
        move_cell( gpoint, direction, -1 )
      end

      # Do what's necessary to move to the next and previous cell in the
      # specified direction, teturning whether it's valid
      def move_cell( gpoint, direction, increment )
        fail "Direction: '#{direction}'" unless [:across, :down].include? direction

        gpoint = gpoint.offset( 0, increment ) if direction == :across
        gpoint = gpoint.offset( increment, 0 ) if direction == :down

        return nil if gpoint.out_of_range?( grid ) ||
                      grid.cell_at( gpoint ).blank?

        gpoint
      end

      # Move the cursor repeatedly in the specified direction, skipping blanks,
      # and stopping at the four edges.
      def move_cursor( gpoint, rinc, cinc )
        new_point = gpoint.offset( rinc, cinc )

        loop do
          return gpoint if new_point.out_of_range?( grid )
          break unless grid.cell_at( new_point ).blank?
          new_point = new_point.offset( rinc, cinc )
        end

        new_point
      end
    end
  end
end
