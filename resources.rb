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
        o_title:  Gosu::Font.new( window, Gosu.default_font_name, 24 )
      }
    end
    
    def self.images( window )
      {
        ankh:   Gosu::Image.new( window, 'media/ankh.png', true )
      }      
    end
  end
end
