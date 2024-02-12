# require 'barby'
# require 'barby/barcode/code_128'
# require 'barby/outputter/png_outputter'
# require 'chunky_png'

module PrintoutImageService
  # def self.generate_barcode_with_text(barcode_data, lines_above, lines_below)
  #   barcode = Barby::Code128B.new(barcode_data)
  #   barcode_image = barcode.to_png(xdim: 1)
    
  #   # Calculate the dimensions of the barcode image
  #   barcode_width =  10
  #   barcode_height = 12
    
  #   # Calculate the height of the text above and below the barcode
  #   text_height = 15
  #   total_height = barcode_height + (text_height * (lines_above + lines_below))
    
  #   # Create a new image with the calculated dimensions
  #   image = ChunkyPNG::Image.new(barcode_width, total_height + 1, ChunkyPNG::Color::WHITE)
    
  #   # Draw the barcode on the image
  #   image.compose!(barcode_image, 0, lines_above * text_height)
    
  #   # Set the font and text options
  #   font = ChunkyPNG::Font.new('Arial', 12)
  #   text_color = ChunkyPNG::Color::BLACK
    
  #   # Draw the lines of text above the barcode
  #   lines_above.times do |i|
  #     draw_text(image, font, barcode_width, i * text_height, "Line #{i + 1} above", text_color)
  #   end
    
  #   # Draw the lines of text below the barcode
  #   lines_below.times do |i|
  #     draw_text(image, font, barcode_width, (lines_above + 1 + i) * text_height + barcode_height, "Line #{i + 1} below", text_color)
  #   end
    
  #   image
  # end

  # private

  # def draw_text(image, font, width, y, text, color)
  #   x = (width - font.width(text)) / 2
  #   font.write(image, x, y, text, color)
  # end
  
  end






