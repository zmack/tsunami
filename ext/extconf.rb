require 'mkmf'

puts `pkg-config --cflags sndfile`
$CFLAGS = `pkg-config --cflags sndfile`.chop
$LDFLAGS = `pkg-config --libs sndfile`.chop

unless find_library 'sndfile', 'sf_open'
  raise 'You need to install libsndfile (http://www.mega-nerd.com/libsndfile/)'
  exit
end

create_makefile 'tsunami_ext'
