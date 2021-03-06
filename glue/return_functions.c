#include <mruby.h>
#include <mruby/class.h>
#include <mruby/data.h>
#include <string.h>

extern struct RClass* get_object_class(mrb_state* mrb) {

    return mrb->object_class;

}

extern mrb_value get_nil_value() {

    return mrb_nil_value();

}

extern mrb_value get_false_value() {

    return mrb_false_value();
  
}

extern mrb_value get_true_value() {

    return mrb_true_value();
  
}

extern mrb_value get_fixnum_value(mrb_int value) {

    return mrb_fixnum_value(value);

}

extern mrb_value get_bool_value(mrb_bool value) {

    return mrb_bool_value(value);

}

extern mrb_value get_float_value(mrb_state* mrb, mrb_float value) {

    return mrb_float_value(mrb, value);

}

extern mrb_value get_string_value(mrb_state* mrb, char* value) {

    return mrb_str_new(mrb, value, strlen(value));

}
