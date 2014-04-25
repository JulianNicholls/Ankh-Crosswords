require 'gosu_enhanced'

module Crossword
  # Resource Loader
  class ResourceLoader
    def self.fonts( window )
      {
        cell:       Gosu::Font.new( window, 'Arial', 15 ),
        number:     Gosu::Font.new( window, 'Arial', 8 ),
        clue:       Gosu::Font.new( window, 'Arial', 11 ),
        header:     Gosu::Font.new( window, 'Arial', 22 )
      }
    end

=begin
    def self.images( window )
      {
        background: Gosu::Image.new( window, 'media/background.png', true ),
        letter:     Gosu::Image.new( window, 'media/letter-bg.png', true ),
        selected:   Gosu::Image.new( window, 'media/letter-selected-bg.png', true )
      }
    end

    def self.sounds( window )
      {
        ok:   Gosu::Sample.new( window, 'media/ok.wav' ),
        uhuh: Gosu::Sample.new( window, 'media/uhuh.wav' ),
        blip: Gosu::Sample.new( window, 'media/blip.wav' )
      }
    end
=end
  end
end
