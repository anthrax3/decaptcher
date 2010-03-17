require "rubygems"
require "RMagick"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require "ocr4r"

FONT_STYLE = {:normal => Magick::NormalStyle, :italic => Magick::ItalicStyle, :oblique => Magick::ObliqueStyle}
FONT_WEIGHT = {:normal => Magick::NormalWeight, :bold => Magick::BoldWeight}
char = 'M'

font_family = 'arial'
threshold = 0x8000
`rm -r perfect_chars/*`

while char <= 'P'
  FONT_STYLE.each_pair do |style_key, style_value|
    FONT_WEIGHT.each_pair do |weight_key, weight_value|
      image = Magick::Image.new(16, 16)
      sample = Magick::Draw.new
      sample.font_family(font_family)
      sample.font_weight(weight_value)
      sample.font_style(style_value)

      sample.pointsize(12)

      sample.text(1, 10, char)
      sample.draw(image)
      image = image.black_threshold(threshold)
      image = image.white_threshold(threshold)
      
      image.write("perfect_chars/[#{char}]-#{font_family}_#{weight_key}_#{style_key}.bmp")
    end
  end
  
  char = (char[0] + 1).chr
end

weights = YAML.load_file("config_test.yml")["ai"]["weights"]
solver = OCR4R::Solver.new(:hidden_neurons => [300, 120], :weights => weights)
directory = "perfect_chars"
weights = solver.train(directory)
opt = {"ai" => {"weights" => weights}}
File.open("config1.yml", 'w') {|f| f.write(opt.to_yaml) }

veio = solver.solve("#{directory}/[M]-arial_bold_normal.bmp")

puts "veio: #{veio}"
