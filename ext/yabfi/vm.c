#include <ruby.h>

/**
 * Initially, the 256 ints are allocated for the VM. Whenever the memory_cursor
 * advances beyond that, the memory size is doubled until it reaches 32768, at
 * which point it will only allocate chunks of that size.
 */
#define INITIAL_MEMORY_SIZE 256
#define MAX_REALLOCATION 32768

/**
 * Size of the temporary buffer used by PUT instructions.
 */
#define INITIAL_BUFFER_SIZE 32

/**
 * Constants that map human readable names to instruction codes.
 */
#define INSTRUCTION_CHANGE_VALUE 0
#define INSTRUCTION_CHANGE_POINTER 1
#define INSTRUCTION_GET 2
#define INSTRUCTION_PUT 3
#define INSTRUCTION_BRANCH_IF_ZERO 4
#define INSTRUCTION_BRANCH_NOT_ZERO 5

/**
 * This struct represents a VM instruction.
 */
typedef struct {
  int code;
  int argument;
} instruction;

/**
 * This struct contains the state of the VM.
 */
typedef struct {
  VALUE input;
  VALUE output;
  int eof;

  instruction *instructions;
  size_t instructions_size;
  size_t program_counter;

  int *memory;
  size_t memory_size;
  size_t memory_cursor;

  char *buffer;
  size_t buffer_size;
} vm;

/**
 * Ruby classes in C!
 */

static VALUE rb_cYABFI;
static VALUE rb_cBaseError;

/**
 * Document-class: YABFI::VM
 *
 * This class, which is implemented as a C extension, executes the
 * instructions generated by the upstream ruby pipeline.
 */
static VALUE rb_cVM;
/**
 * Document-class: YABFI::VM::InvalidCommand
 *
 * Raised when an InvalidCommand is received by the VM.
 */
static VALUE rb_cInvalidCommand;

/**
 * Document-class: YABFI::VM::MemoryOutOfBounds
 *
 * Raised when the memory cursor is moved below zero.
 */
static VALUE rb_cMemoryOutOfBounds;

/**
 * Free the allocated memory for the virtual machine.
 */
static void
vm_free(void *p) {
  vm *ptr = p;

  if (ptr->instructions_size > 0) {
    free(ptr->instructions);
  }

  if (ptr->memory_size > 0) {
    free(ptr->memory);
  }

  if (ptr->buffer_size > 0) {
    free(ptr->buffer);
  }
}

/**
 * Allocate a new VM.
 */
static VALUE
vm_alloc(VALUE klass) {
  VALUE instance;
  vm *ptr;

  instance = Data_Make_Struct(klass, vm, NULL, vm_free, ptr);

  ptr->input = Qnil;
  ptr->output = Qnil;
  ptr->eof = 0;

  ptr->instructions = NULL;
  ptr->instructions_size = 0;
  ptr->program_counter = 0;

  ptr->memory = NULL;
  ptr->memory_size = 0;
  ptr->memory_cursor = 0;

  ptr->buffer = NULL;
  ptr->buffer_size = 0;

  return instance;
}

/**
 * Initialize a new VM.
 *
 * @param input [IO] the input from which the VM reads.
 * @param output [IO] the output to which the VM writes.
 * @param eof [Fixnum] the value to return when EOF is reached.
 *
 * @!parse [ruby]
 *  class YABFI::VM
 *    def initialize(input, output, eof)
 *    end
 *  end
 */
static VALUE
vm_initialize(VALUE self, VALUE input, VALUE output, VALUE rb_eof) {
  vm *ptr;

  Check_Type(rb_eof, T_FIXNUM);
  Data_Get_Struct(self, vm, ptr);

  ptr->input = input;
  ptr->output = output;
  ptr->eof = NUM2INT(rb_eof);

  return self;
};

/**
 * Load the VM with new instructions.
 *
 * @param ary [Array<Object>] list of instructions to execute.
 * @return [nil] unconditionally.
 *
 * @!parse [ruby]
 *  class YABFI::VM
 *    def load!(ary)
 *    end
 *  end
 */
static VALUE
vm_load(VALUE self, VALUE ary) {
  int iter;
  vm *ptr;
  VALUE entry, code, arg;

  Data_Get_Struct(self, vm, ptr);

  Check_Type(ary, T_ARRAY);

  vm_free(ptr);

  ptr->memory_cursor = 0;
  ptr->memory_size = INITIAL_MEMORY_SIZE;
  ptr->memory = calloc(INITIAL_MEMORY_SIZE, sizeof(int));

  ptr->program_counter = 0;
  ptr->instructions_size = RARRAY_LEN(ary);
  ptr->instructions = malloc(sizeof(instruction) * ptr->instructions_size);

  ptr->buffer_size = INITIAL_BUFFER_SIZE;
  ptr->buffer = malloc(INITIAL_BUFFER_SIZE * sizeof(char));

  for (iter = 0; iter < (int) ptr->instructions_size; iter++) {
    entry = rb_ary_entry(ary, iter);
    Check_Type(entry, T_ARRAY);
    if (RARRAY_LEN(entry) != 2) {
      rb_raise(rb_cInvalidCommand, "Commands must be tuples");
    }
    code = rb_ary_entry(entry, 0);
    arg = rb_ary_entry(entry, 1);
    Check_Type(code, T_FIXNUM);
    Check_Type(arg, T_FIXNUM);
    ptr->instructions[iter] = (instruction) { FIX2INT(code), FIX2INT(arg) };
  }

  return Qnil;
}

/**
 * Execute the instructions loaded into the VM.
 *
 * @raise [MemoryOutOfBounds] when the memory cursor goes below zero.
 * @raise [InvalidCommand] when an invalid command is executed.
 * @return [nil] unconditionally.
 *
 * @!parse [ruby]
 *  class YABFI::VM
 *    def execute!
 *    end
 *  end
 */
static VALUE
vm_execute(VALUE self) {
  vm *ptr;
  int *tmp_memory;
  int delta;
  int iter;
  instruction curr;

  Data_Get_Struct(self, vm, ptr);

  while (ptr->program_counter < ptr->instructions_size) {
    curr = ptr->instructions[ptr->program_counter];
    switch (curr.code) {
      case INSTRUCTION_CHANGE_VALUE:
        ptr->memory[ptr->memory_cursor] += curr.argument;
        ptr->program_counter++;
        break;
      case INSTRUCTION_CHANGE_POINTER:
        if (((int) ptr->memory_cursor + curr.argument) < 0) {
          rb_raise(rb_cMemoryOutOfBounds, "The memory cursor went below zero");
        }
        ptr->memory_cursor += curr.argument;
        while (ptr->memory_cursor >= ptr->memory_size) {
          delta = ptr->memory_size;
          if (delta > MAX_REALLOCATION) {
            delta = MAX_REALLOCATION;
          }
          tmp_memory = ptr->memory;
          ptr->memory = malloc((ptr->memory_size + delta) * sizeof(int));
          memcpy(ptr->memory, tmp_memory, ptr->memory_size * sizeof(int));
          memset(ptr->memory + ptr->memory_size, 0, delta * sizeof(int));
          ptr->memory_size += delta;
          free(tmp_memory);
        }
        ptr->program_counter++;
        break;
      case INSTRUCTION_BRANCH_IF_ZERO:
        if (ptr->memory[ptr->memory_cursor] == 0) {
          ptr->program_counter += curr.argument;
        } else {
          ptr->program_counter++;
        }
        break;
      case INSTRUCTION_BRANCH_NOT_ZERO:
        if (ptr->memory[ptr->memory_cursor] != 0) {
          ptr->program_counter += curr.argument;
        } else {
          ptr->program_counter++;
        }
        break;
      case INSTRUCTION_GET:
        for (iter = 0; iter < curr.argument; iter++) {
          if (rb_funcall(ptr->input, rb_intern("eof?"), 0)) {
            ptr->memory[ptr->memory_cursor] = ptr->eof;
          } else {
            ptr->memory[ptr->memory_cursor] =
              FIX2INT(rb_funcall(ptr->input, rb_intern("getbyte"), 0));
          }
        }
        ptr->program_counter++;
        break;
      case INSTRUCTION_PUT:
        if (ptr->buffer_size < curr.argument) {
          free(ptr->buffer);
          ptr->buffer_size = curr.argument;
          ptr->buffer = malloc(ptr->buffer_size * sizeof(char));
        }
        memset(ptr->buffer, ptr->memory[ptr->memory_cursor],
            curr.argument * sizeof(char));
        rb_funcall(ptr->output, rb_intern("write"), 1,
            rb_str_new(ptr->buffer, curr.argument));
        ptr->program_counter++;
        break;
      default:
        rb_raise(rb_cInvalidCommand, "Invalid command code: %i", curr.code);
    }
  }

  return Qnil;
}

/**
 * Return the VM's internal state -- used in testing and debugging.
 */
static VALUE
vm_state(VALUE self) {
  vm *ptr;
  VALUE hash;

  Data_Get_Struct(self, vm, ptr);
  hash = rb_hash_new();

  rb_hash_aset(hash, ID2SYM(rb_intern("memory_cursor")),
      INT2FIX(ptr->memory_cursor));
  rb_hash_aset(hash, ID2SYM(rb_intern("memory_size")),
      INT2FIX(ptr->memory_size));
  rb_hash_aset(hash, ID2SYM(rb_intern("program_counter")),
      INT2FIX(ptr->program_counter));
  if (ptr->memory_cursor < ptr->memory_size) {
    rb_hash_aset(hash, ID2SYM(rb_intern("current_value")),
        INT2FIX(ptr->memory[ptr->memory_cursor]));
  } else {
    rb_hash_aset(hash, ID2SYM(rb_intern("current_value")), Qnil);
  }

  return hash;
}

/**
 * Initialize the C extension by defining all of the classes and methods.
 */
void
Init_vm(void) {
  rb_cYABFI = rb_const_get(rb_cObject, rb_intern("YABFI"));
  rb_cBaseError = rb_const_get(rb_cYABFI, rb_intern("BaseError"));

  rb_cVM = rb_define_class_under(rb_cYABFI, "VM", rb_cObject);
  rb_cInvalidCommand =
    rb_define_class_under(rb_cVM, "InvalidCommand", rb_cBaseError);
  rb_cMemoryOutOfBounds =
    rb_define_class_under(rb_cVM, "MemoryOutOfBounds", rb_cBaseError);

  rb_define_alloc_func(rb_cVM, vm_alloc);
  rb_define_method(rb_cVM, "initialize", vm_initialize, 3);
  rb_define_method(rb_cVM, "load!", vm_load, 1);
  rb_define_method(rb_cVM, "execute!", vm_execute, 0);
  rb_define_method(rb_cVM, "state", vm_state, 0);
}
