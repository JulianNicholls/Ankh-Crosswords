module WordThing
  class WordGrid
    # Grid Point
    class GPoint < Struct.new( :col, :row )
      include Constants

      def offset( x, y )
        GPoint.new( col + x, row + y )
      end

      def to_point
        GRID_ORIGIN.offset( col * TILE_SIZE, row * TILE_SIZE )
      end

      def self.from_point( pos )
        GPoint.new(
          ((pos.x - GRID_ORIGIN.x) / TILE_SIZE).floor,
          ((pos.y - GRID_ORIGIN.y) / TILE_SIZE).floor
        )
      end
    end
  end
end
