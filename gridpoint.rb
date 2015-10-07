require 'constants'

module Crossword
  # Represent a cell position in the grid
  GridPoint = Struct.new(:row, :col) do
    include Constants

    def self.from_point(pos)
      from_xy(pos.x, pos.y)
    end

    def self.from_xy(x, y)
      new(
        ((y - GRID_ORIGIN.y) / CELL_SIZE.height).floor,
        ((x - GRID_ORIGIN.x) / CELL_SIZE.width).floor
      )
    end

    def out_of_range?(height, width = nil)
      return true if row < 0 || col < 0

      if height.respond_to? :height
        width  = height.width
        height = height.height
      end

      row >= height || col >= width
    end

    def offset(dr, dc = nil)
      if dr.respond_to? :row
        GridPoint.new(row + dr.row, col + dr.col)
      else
        GridPoint.new(row + dr, col + dc)
      end
    end

    def to_point
      GRID_ORIGIN.offset(col * CELL_SIZE.width, row * CELL_SIZE.height)
    end
  end
end
