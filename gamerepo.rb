module Crossword
  # Game information holder
  class Game < Struct.new( :filename, :grid, :title, :elapsed )
  end

  # Repository worker for loading .puz files, and for saving and loading
  # .ankh files
  class GameRepository
    def self.load( filename )
      # First attempt to load a game in progress
      
      game = load_ankh_file( filename )
      return game unless game.nil?

      # There's no .ankh file, so oad the normal .puz file
      
      puz  = PuzzleLoader.new( filename )
      grid = Crossword::Grid.new( puz.rows, puz.clues )

      Game.new( filename, grid, "#{puz.title} - #{puz.author}", 0 )
    end

    def self.load_ankh_file( filename )
      ankh_filename = filename.sub( /\.[^\.]+\z/, '.ankh' )
      puts "Ankh file: #{ankh_filename}"

      return nil unless File.exist? ankh_filename

      title, elapsed, grid = '', 0, nil
      
      open( ankh_filename, 'r' ) do |file|
        title = file.gets.strip
        elapsed = file.gets.strip.to_f
        grid = Grid.from_ankh_file( file )
      end
      
      Game.new( filename, grid, title, elapsed )
    end
    
    def self.save_ankh_file( game )
      ankh_filename = game.filename.sub( /\.[^\.]+\z/, '.ankh' )
      
      open( ankh_filename, 'w' ) do |file|
        file.puts game.title
        file.puts game.elapsed.floor
        file.puts "#{game.grid.width},#{game.grid.height}"
        game.grid.each_with_position { |cell, _| file.puts cell.to_text }
        game.grid.clues.each { |clue| file.puts clue.to_text }
      end
    end    
  end
end
