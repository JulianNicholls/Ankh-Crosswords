require 'constants'

module Crossword
  # Draw sections of the game
  class Drawer
    include Constants

    def initialize( window )
      @window = window
    end

    def background
      # All White
      origin = Point.new( 0, 0 )
      size   = Size.new( @window.width, @window.height )
      @window.draw_rectangle( origin, size, 0, WHITE )

      clue_area( origin, size )

      # Grid Area
      origin = GRID_ORIGIN.offset( -1 * MARGIN, -1 * MARGIN )
      size   = @window.grid.size.inflate( MARGIN * 2, MARGIN * 2 )
      @window.draw_rectangle( origin, size, 0, BACKGROUND )
    end

    def grid( show_errors )
      @window.grid.each_with_position do |cell, gpoint|
        pos = gpoint.to_point
        @window.draw_rectangle( pos, CELL_SIZE, 1, BLACK )
        cell( pos, cell, show_errors ) unless cell.blank?
      end
    end

    def clues( current )
      across_point = Point.new( ACROSS_LEFT, MARGIN * 2 )
      down_point   = Point.new( DOWN_LEFT, MARGIN * 2 )

      clue_header( across_point, 'Across' )
      clue_header( down_point, 'Down' )

      clue_list_with_current( across_point, :across, current )
      clue_list_with_current( down_point, :down, current )
    end

    private

    def clue_area( origin, size )
      origin.move_by!( MARGIN, MARGIN )
      size.deflate!( @window.grid.size.width + MARGIN * 5, MARGIN * 2 )
      @window.draw_rectangle( origin, size, 0, BACKGROUND )

      ankh      = @window.image[:ankh]
      icon_left = (size.width  - ankh.width) / 2
      icon_top  = (size.height - ankh.height) / 2
      ankh.draw( icon_left, icon_top, 1 )
    end

    def cell( pos, cell, show_errors )
      bk = BK_COLOURS[cell.highlight]

      if cell.highlight == :none && cell.error && show_errors
        bk = BK_COLOURS[:wrong]
      end

      @window.draw_rectangle( pos.offset( 1, 1 ), CELL_SIZE.deflate( 2, 2 ), 1, bk )

      cell_number( pos, cell.number )       unless cell.number == 0
      cell_letter( pos, cell, show_errors ) unless cell.empty?
    end

    def cell_number( pos, number )
      @window.font[:number].draw( number, pos.x + 2, pos.y + 1, 2, 1, 1, BLACK )
    end

    def cell_letter( pos, cell, show_errors )
      cf     = @window.font[:cell]
      lpos   = pos.offset( cf.centred_in( cell.user, CELL_SIZE ) )
      colour = cell.error && show_errors ? ERROR_FG : BLACK
      cf.draw( cell.user, lpos.x, lpos.y + 1, 2, 1, 1, colour )
    end

    def clue_header( pos, header )
      hf = @window.font[:header]
      hf.draw( header, pos.x, pos.y, 2, 1, 1, WHITE )

      pos.move_by!( 0, hf.height + 1 )
    end

    # Render the clue list off screen first if it's the list with the current clue,
    # then redraw it where asked, potentially not from the start if the current
    # clue wouldn't be displayed.

    def clue_list_with_current( pos, dir, current )
      list = @window.grid.clues_of( dir )
      current_list = current.dir == dir
      skip = 0

      if current_list
        off_screen = pos.offset( @window.width, 0 )
        skip = clue_list( off_screen, list, current_list, current.number )
      end

      clue_list( pos, list[skip..-1], current_list, current.number )
    end

    # Draw the list of clues, ensuring that the current one is on screen, and
    # not at the extreme bottom

    def clue_list( pos, list, current_list, number )
      found = -1
      shown = 0

      list.each_with_index do |clue, idx|
        is_current = current_list && number == clue.number
        found = idx if is_current

        lh = clue.draw( @window, pos, CLUE_COLUMN_WIDTH, is_current )
        shown += 1

        break if pos.y >= @window.height - (MARGIN + lh)
      end

      adjustment( list, current_list, shown, found )
    end

    def adjustment( list, current_list, shown, found )
      # If it's not the current list, we just show the beginning
      return 0 unless current_list

      # If it's not there, show the end
      return list.size - shown if found == -1

      # If we're nearing the bottom, move it up a bit
      return ((list.size - shown) / 2).floor if (shown - found) < 4

      # Otherwise, everything's hunky-dory
      0
    end
  end
end
