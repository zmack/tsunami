#this class was inspired by rjp's awesome http://github.com/rjp/cdcover
require 'rubygems'
require 'RMagick'
require 'narray'

class Tsunami

  def initialize audio_file
    # graph parameters
    @bitrate = '500'
    @offset = 5
    @audio_file = audio_file
  end

  def create_waveform(image_file, options)
    @width = options[:width].to_i || 100
    @height = options[:height].to_i || 50

    buckets = fill_buckets

    gc = build_graph buckets

    #create new image canvas
    canvas = Magick::Image.new(@width + 2*@offset, @height) { self.background_color = 'transparent' }

    # canvas = Magick::ImageList.new('images/waveform.png')
    gc.draw(canvas)

    canvas.write(image_file)
  end

  #fill the buckets
  def fill_buckets
    buckets = NArray.int(@width,2)

    #let sox fetch the byte array
    bytes = wave_bytes

    bucket_size = (((bytes.size-1).to_f / @width)+0.5).to_i + 1

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

  def wave_bytes
    @wave_bytes ||= sox_get_bytes
  end

  #open file with sox and return a byte array with sweet waveform information in it
  def sox_get_bytes channels = 1
    x=nil
    # read a 16 bit linear raw PCM file
    sox_command = [ 'sox', @audio_file, '-t', 'raw', '-r', @bitrate, '-c', channels.to_s, '-s', '-L', '-' ]
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
  def build_graph buckets
    gc = Magick::Draw.new

    scale = 32768/@height*2.75
    midpoint = @height/2

    (0..(buckets.size/2)-1).each do |i|
      low = buckets[i,0]
      high = buckets[i,1]
      gc.stroke('red')
      gc.stroke_width(1)
      low_point = midpoint+low/scale
      high_point = midpoint+high/scale
      gc.line(i+@offset, low_point.to_i, i+@offset, high_point.to_i)
    end

    return gc
  end
end
