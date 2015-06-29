#include <ruby.h>

/**
 * Initialize the C extension.
 */
void Init_vm(void) {
  VALUE rb_cYABFI = rb_const_get(rb_cObject, rb_intern("YABFI"));
  rb_define_class_under(rb_cYABFI, "VM", rb_cObject);
}
