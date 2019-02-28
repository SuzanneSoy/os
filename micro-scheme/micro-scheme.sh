#!/bin/sh

heap_init() {
  heap_max=0
}

alloc_cons_ptr_ptr_unit() {
  # args:     $1 must be an heap pointer (non-negative integer)
  #           $2 must be an heap pointer (non-negative integer)
  # input:    heap_max
  # output:   heap_max++ heap_type_$heap_max heap_car_$heap_max heap_cdr_$heap_max
  # clobbers: none
  # warning:  does no attempt to escape ", \, $, space and so on in any of the inputs or outputs.

  # heap_max++
  heap_max=$((heap_max+1))
  # heap_type[heap_max] = C
  eval heap_type_$heap_max=C
  # heap_car[heap_max] = $1
  eval heap_car_$heap_max='"'$1'"'
  # heap_cdr[heap_max] = $2
  eval heap_cdr_$heap_max='"'$2'"'
}

alloc_primitive_hex_unit() {
  # args:     $1 must be a hexadecimal string
  # input:    heap_max
  # output:   heap_max++ heap_type_$heap_max heap_value_$heap_max
  # clobbers: none
  # warning:  does no attempt to escape ", \, $, space and so on in any of the inputs or outputs.

  # heap_max++
  heap_max=$((heap_max+1))
  # heap_type[heap_max] = P
  eval heap_type_$heap_max=P
  # heap_value[heap_max] = $1
  eval heap_value_$heap_max='"'$1'"'
}

car() {
  eval 'printf %s "$heap_car_'$1'"'
}

cdr() {
  eval 'printf %s "$heap_cdr_'$1'"'
}

value() {
  eval 'printf %s "$heap_value_'$1'"'
}

debug_print() {
  eval 'tmpdebug=$heap_type_'"$1"
  if test $tmpdebug = C; then
    printf '('
    eval 'tmpdebugb=$heap_car_'$1
    (debug_print $tmpdebugb)
    printf ' . '
    eval 'tmpdebugb=$heap_cdr_'$1
    (debug_print $tmpdebugb)
    printf ')'
  else
    eval 'printf "[%s]" "$heap_value_'$1'"'
  fi
}

stack_init_name_unit() {
  eval "stacklast_${1}=0"
}

stack_push_name_hex_unit() {
  # args:     $1 must be an [a-z]+ name
  #           $2 must be a hexadecimal string
  # input:    stacklast_$1
  # output:   stacklast_$1 stack_$1_${!stacklast_$1+1}
  # clobbers: stacklast
  # warning:  does no attempt to escape ", \, $, space and so on in any of the inputs or outputs.
  eval stacklast='${'stacklast_${1}'}'
  stacklast=$((${stacklast}+1))
  echo stack_${1}_${stacklast}='"'${2}'"'
  eval stack_${1}_${stacklast}='"'${2}'"'
  eval stacklast_${1}=${stacklast}
}

stack_len_name_int() {
  # args:     $1 must be an [a-z]+ name
  # input:    stacklast_$1
  # output:   stdout=${!stacklast_$1}
  # clobbers: nothing
  # warning:  does no attempt to escape ", \, $, space and so on in any of the inputs or outputs.
  eval 'printf %s ${'stacklast_${1}'}'
}

stack_pop_name_result_unit() {
  # args:     $1 must be an [a-z]+ name
  # input:    stacklast_$1
  # output:   stacklast_$1 stack_$1_${!stacklast_$1}
  # clobbers: stacklast
  # warning:  does no attempt to escape ", \, $, space and so on in any of the inputs or outputs.
  eval stacklast='${'stacklast_${1}'}'
  eval $2'="${'stack_${1}_${stacklast}'}"'
  stacklast=$((${stacklast}-1))
  eval stacklast_${1}=${stacklast}
}

stack_peek_name_hex() {
  # args:     $1 must be an [a-z]+ name
  # input:    stacklast_$1 stack_$1_${!stacklast_$1}
  # output:   stdout
  # clobbers: stacklast
  # warning:  does no attempt to escape ", \, $, space and so on in any of the inputs or outputs.
  eval stacklast='${'stacklast_${1}'}'
  eval 'printf %s "${'stack_${1}_${stacklast}'}"'
}

stack_init_name_unit parse_stack
stack_push_name_hex_unit parse ''

heap_init
alloc_primitive_hex_unit "Int 42"
alloc_primitive_hex_unit "Sym toto"
alloc_cons_ptr_ptr_unit 1 $heap_max

printf '(+ 1   ( +  22 345 ))' | \
od -v -A n -t x1 | sed -e 's/^ //' | tr ' ' \\n | (while read c; do
  case "$c" in
   # Open paren
   28) if test "x$(stack_peek_name_hex parse)" = 'x'; then
         stack_pop_name_result_unit parse current
       fi
       stack_push_name_hex_unit parse 2028
       stack_push_name_hex_unit parse '';;
   # Close paren
   29) if test "x$(stack_peek_name_hex parse)" = 'x'; then
         stack_pop_name_result_unit parse current
       else
         stack_pop_name_result_unit parse current
         alloc_primitive_hex_unit "Sym $current"
         stack_push_name_hex_unit parse $heap_max
       fi
       alloc_primitive_hex_unit "Nil"
       cdr=$heap_max
       while test "x$(stack_peek_name_hex parse)" != 'x2028'; do
         stack_pop_name_result_unit parse current
         car=$current
         alloc_cons_ptr_ptr_unit $car $cdr
         cdr=$heap_max
       done
       stack_pop_name_result_unit parse current
       stack_push_name_hex_unit parse $cdr;;
   # Space
   20) if test "x$(stack_peek_name_hex parse)" != 'x'; then
         stack_pop_name_result_unit parse current
         alloc_primitive_hex_unit "Sym $current"
         stack_push_name_hex_unit parse $heap_max
         stack_push_name_hex_unit parse ''
       fi;;
   # identifier character
   *) stack_pop_name_result_unit parse current
      stack_push_name_hex_unit parse "$current$c";;
  esac
done

echo stack:

while test "x$(stack_len_name_int parse)" != 'x0'; do
  stack_pop_name_result_unit parse tmp
  echo "$tmp"
done | tac

echo heap:

for i in `seq $heap_max`; do
  eval "echo $i \$heap_type_$i \$heap_car_$i \$heap_cdr_$i \$heap_value_$i"
done

#echo $(value $(cdr $heap_max))

debug_print $heap_max
echo
)
