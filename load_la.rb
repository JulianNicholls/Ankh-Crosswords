require './puzloader'

def debug( name, value )
  printf "%s: %d %04x\n", name, value, value
end

puz = PuzzleLoader.new( '2014-4-22-LosAngelesTimes.puz' )

debug 'Width ', puz.width
debug 'Height', puz.height
debug 'Clues ', puz.num_clues
debug 'Scrambled', puz.scrambled? ? 1 : 0

puts %(
Title:  #{puz.title}
Author: #{puz.author}
Copy:   #{puz.copyright}
)

puz.rows.each { |row| puts row }

puz.clues.each { |clue| puts clue }
