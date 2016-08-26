require 'opencv'
include OpenCV

if ARGV.length < 1
  puts "Usage: ruby #{__FILE__} source dest"
  exit
end

data = './cascade/haarcascade_frontalface_alt.xml'
detector = CvHaarClassifierCascade::load(data)
image = IplImage.load(ARGV[0])

detector.detect_objects(image).each do |region|
  color = CvColor::Gray
  image.rectangle! region.top_left, region.bottom_right, :color => color #ここで顔に枠をつけるよ
  image.set_roi(region) #ここでさらに顔の部分だけを切り取り
end

i3 = image.BGR2GRAY.add(10) #グレスケ
i2 = i3.threshold(128, 255, CV_THRESH_BINARY) #2値化
# i2.save_image(ARGV[1])

black =  i2.count_non_zero
size = i2.width * i2.height
white = size.to_f - black

artistry = (1 - (black * 0.8) / (size / 2.0)) * 100.0
technical = (1 - (white / black)) * 10.0
puts "技術点 = #{technical.round(2)}, 芸術点 = #{artistry.round(2)}"
#window = GUI::Window.new('Face detection')
#window.show(image)
#GUI::wait_key
