/*Include the Ruby headers and goodies*/
#include "ruby.h"
#include "snd_analytics.h"

// Defining a space for information and references about the module to be stored internally
VALUE MyTest = Qnil;

// Prototype for the initialization method - Ruby calls this, not you
void Init_tsunami_ext();

// Prototype for our method 'test1' - methods are prefixed by 'method_' here
VALUE method_get_stats(VALUE self, VALUE path, VALUE samples);

// The initialization method for this module
void Init_tsunami_ext() {
  MyTest = rb_define_module("TsunamiC");
  rb_define_singleton_method(MyTest, "get_stats", method_get_stats, 2);
}

VALUE min_max_hash(float min, float max) {
  VALUE min_symb = ID2SYM(rb_intern("min"));
  VALUE max_symb = ID2SYM(rb_intern("max"));
  
  VALUE hash = rb_hash_new();
  rb_hash_aset(hash, min_symb, rb_float_new(min));
  rb_hash_aset(hash, max_symb, rb_float_new(max));

  return hash;
}

// Our 'test1' method.. it simply returns a value of '10' for now.
VALUE method_get_stats(VALUE self, VALUE rb_path, VALUE rb_samples) {
  TsunamiRange *values;
  VALUE array, hash;

  int i;
  char *path = STR2CSTR(rb_path);
  int samples = FIX2INT(rb_samples);

  array = rb_ary_new();
  
  values = get_stats(path, samples);

  for(i = 0; i < samples; i++) {
    rb_ary_push(array, min_max_hash(values[i].min, values[i].max));
  }

  free(values);

  return array;
}
