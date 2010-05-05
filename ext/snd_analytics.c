#include <stdio.h>
#include <stdlib.h>
#include <sndfile.h>
#include "snd_analytics.h"

const FRAMES_IN_BUFFER = 2000;

TsunamiRange *get_stats(char *path, short sample_count) {
  SNDFILE *file;
  SF_INFO info;
  float *buffer;
  TsunamiRange *samples;
  unsigned int offset = 0, frames_per_sample;
  short i, buffer_size, read_frames, sample_index = 0;

  file = sf_open(path, SFM_READ, &info);
  buffer_size = FRAMES_IN_BUFFER * info.channels * sizeof(float);

  frames_per_sample = info.frames / sample_count;

  buffer = (float *)malloc(buffer_size);

  samples = (TsunamiRange *)malloc(sample_count * sizeof(TsunamiRange));

  for( i = 0; i < sample_count; i++ ) {
    samples[i].min = 1;
    samples[i].max = -1;
  }

  while ( read_frames = sf_readf_float(file, buffer, FRAMES_IN_BUFFER) ) {
    for( i = 0; i < read_frames; i += info.channels ) {
      sample_index = (i + offset) / frames_per_sample;

      if (samples[sample_index].min > buffer[i]) {
        samples[sample_index].min = buffer[i];
      }

      if (samples[sample_index].max < buffer[i]) {
        samples[sample_index].max = buffer[i];
      }
    }
    offset += read_frames;
  }

  free(buffer);
  return samples;
}
