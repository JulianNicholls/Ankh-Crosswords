# Game information holder
Game = Struct.new(:filename, :grid, :title, :elapsed)

# Repository worker for loading .puz files, and for saving and loading
# .ankh files
class GameRepository
  def self.load(filename)
    # First, attempt to load a game in progress

    game = load_ankh_file(filename)
    return game if game

    # There's no .ankh file, so load the normal .puz file

    puz  = PuzzleLoader.new(filename)
    grid = Crossword::Grid.new(puz.rows, puz.clues)

    Game.new(filename, grid, "#{puz.title} - #{puz.author}", 0)
  end

  # Load from the ankh file if it exists
  def self.load_ankh_file(filename)
    ankh = ankh_filename(filename)

    return nil unless File.exist? ankh

    open(ankh, 'r') do |file|
      title   = file.gets.chomp
      elapsed = file.gets.chomp.to_f
      grid    = Crossword::Grid.from_ankh_file(file)

      Game.new(filename, grid, title, elapsed)
    end
  end

  def self.save_ankh_file(game)
    open(ankh_filename(game.filename), 'w') do |file|
      file.puts game.title
      file.puts game.elapsed.floor
      file.puts "#{game.grid.width},#{game.grid.height}"
      write_grid(file, game.grid)
      write_clues(file, game.grid.clues)
    end
  end

  def self.write_grid(file, grid)
    grid.each do |cell|
      file.puts cell.to_text
    end
  end

  def self.write_clues(file, clues)
    clues.each do |clue|
      file.puts clue.to_text
    end
  end

  def self.ankh_filename(filename)
    filename.sub(/\.[^\.]+\z/, '.ankh')
  end
end
