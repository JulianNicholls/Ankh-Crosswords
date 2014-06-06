module Crossword
  # Game information holder
  class Game < Struct.new( :filename, :grid, :title, :elapsed )
  end

  # Repository worker for loading .puz files, and for saving and loading
  # .ankh files
  class GameRepository
    def self.load( filename )
      # First, attempt to load a game in progress

      game = load_ankh_file( filename )
      return game unless game.nil?

      # There's no .ankh file, so load the normal .puz file

      puz  = PuzzleLoader.new( filename )
      grid = Grid.new( puz.rows, puz.clues )

      Game.new( filename, grid, "#{puz.title} - #{puz.author}", 0 )
    end

    # Load from the ankh file if it exists
    def self.load_ankh_file( filename )
      ankh = ankh_filename( filename )

      return nil unless File.exist? ankh

      title, elapsed, grid = '', 0, nil

      open( ankh, 'r' ) do |file|
        title = file.gets.chomp
        elapsed = file.gets.chomp.to_f
        grid = Grid.from_ankh_file( file )
      end

      Game.new( filename, grid, title, elapsed )
    end

    def self.save_ankh_file( game )
      open( ankh_filename( game.filename ), 'w' ) do |file|
        file.puts game.title
        file.puts game.elapsed.floor
        file.puts "#{game.grid.width},#{game.grid.height}"
        game.grid.each_with_position { |cell, _| file.puts cell.to_text }
        game.grid.clues.each { |clue| file.puts clue.to_text }
      end
    end

    def self.ankh_filename( filename )
      filename.sub( /\.[^\.]+\z/, '.ankh' )
    end
  end
end
