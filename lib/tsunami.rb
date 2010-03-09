#this class was inspired by rjp's awesome http://github.com/rjp/cdcover
require 'rubygems'
require 'RMagick'
require 'narray'

class Tsunami

  attr_accessor :size, :width, :height
  attr_accessor :audio_file, :image_file
  attr_accessor :bitrate
  attr_accessor :offset

  def initialize size, audio_file, image_file
    # graph parameters
    @size = size
    @width = (@size).to_i
    @height = 130
    @bitrate = '500'
    @offset = 5
    @audio_file = audio_file
    @image_file = image_file
    #testing_parameters
  end

  def create_waveform_image
    buckets = fill_buckets width,@audio_file
    p buckets
    p size
    gc = build_graph buckets,size
    #create new image canvas
    canvas = Magick::Image.new(@width + 20, @height) { self.background_color = 'transparent' }
    # canvas = Magick::ImageList.new('images/waveform.png')
    gc.draw(canvas)
    canvas.write(@image_file)
  end

  #fill the buckets
  def fill_buckets width,file
    buckets = NArray.int(width,2)
    #let sox fetch the byte array
    bytes = sox_get_bytes file
    bucket_size = (((bytes.size-1).to_f / width)+0.5).to_i + 1
    (0..bytes.total-1).each do |i|
      value = bytes[i]
      index = i/bucket_size
      #minimum
      buckets[index,0] = value if value < buckets[index,0]
      #maximum
      buckets[index,1] = value if value > buckets[index,1]
      #total value
      #buckets[index,2] += value
      #count
      #buckets[index,3] += 1
      #negative total
      #buckets[index,4] += value if value < 0
      #positive total
      #buckets[index,5] += value if value > 0
    end
    return buckets
  end

  #open file with sox and return a byte array with sweet waveform information in it
  def sox_get_bytes file, channels = 1
    x=nil
    # read a 16 bit linear raw PCM file
    sox_command = [ 'sox', file, '-t', 'raw', '-r', @bitrate, '-c', channels.to_s, '-s', '-L', '-' ]
    # we have to fork/exec to get a clean commandline
    IO.popen('-') { |p|
      if p.nil? then
        $stderr.close
        # raw 16 bit linear PCM one channel
        exec *sox_command
      end
      x = p.read
    }
    if x.size == 0 then
      puts "sox returned no data, command was\n> #{sox_command.join(' ')}"
      exit 1
    end
    return NArray.to_na(x.unpack("s*"))
  end

  #build the waveform graph
  def build_graph buckets,size
    gc = Magick::Draw.new
    scale = 32768/@height*2.75
    midpoint = @height/2
    p buckets.size
    (0..(buckets.size/2)-1).each do |i|
      low = buckets[i,0]
      high = buckets[i,1]
      gc.stroke('red')
      gc.stroke_width(1)
      low_point = midpoint+low/scale
      high_point = midpoint+high/scale
      gc.line(i+@offset, low_point.to_i, i+@offset, high_point.to_i)
      puts "#{i+@offset}, #{low_point.to_i}, #{i+@offset}, #{high_point.to_i}"
    end
    return gc
  end
end
