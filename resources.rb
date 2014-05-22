require 'gosu_enhanced'

module Crossword
  # Resource Loader
  class ResourceLoader
    def self.fonts( window )
      {
        cell:     Gosu::Font.new( window, Gosu.default_font_name, 16 ),
        number:   Gosu::Font.new( window, Gosu.default_font_name, 8 ),
        clue:     Gosu::Font.new( window, Gosu.default_font_name, 11 ),
        header:   Gosu::Font.new( window, Gosu.default_font_name, 19 ),
        button:   Gosu::Font.new( window, Gosu.default_font_name, 11 )
#        cell:     Gosu::Font.new( window, 'Verdana', 15 ),
#        number:   Gosu::Font.new( window, 'Verdana', 8 ),
#        clue:     Gosu::Font.new( window, 'Verdana', 11 ),
#        header:   Gosu::Font.new( window, 'Verdana', 20 ),
#        button:   Gosu::Font.new( window, 'Verdana', 11 )
      }
    end

#    def self.images( window )
#      {
#        background: Gosu::Image.new( window, 'media/background.png', true ),
#        letter:     Gosu::Image.new( window, 'media/letter-bg.png', true ),
#        selected:   Gosu::Image.new( window, 'media/letter-selected-bg.png', true )
#      }
#    end
#
#    def self.sounds( window )
#      {
#        ok:   Gosu::Sample.new( window, 'media/ok.wav' ),
#        uhuh: Gosu::Sample.new( window, 'media/uhuh.wav' ),
#        blip: Gosu::Sample.new( window, 'media/blip.wav' )
#      }
#    end
  end
end
