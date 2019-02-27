#!/bin/sh

stack_init_name_unit() {
  eval "stacklast_${1}="
}

stack_push_name_hex_unit() {
  # args:     $1 must be an [a-z]+ name
  #           $2 must be a hexadecimal string
  # input:    stacklast_$1
  # output:   stacklast_$1 stack_$1_${!stacklast_$1}
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

printf '(+ 1   ( +  22 345 ))' | \
od -v -A n -t x1 | sed -e 's/^ //' | tr ' ' \\n | (while read c; do
  case "$c" in
   # Open paren
   28) if test "x$(stack_peek_name_hex parse)" = 'x'; then
         stack_pop_name_result_unit parse current
       fi
       stack_push_name_hex_unit parse 28
       stack_push_name_hex_unit parse '';;
   # Close paren
   29) if test "x$(stack_peek_name_hex parse)" = 'x'; then
         stack_pop_name_result_unit parse current
       fi
       stack_push_name_hex_unit parse 29;;
   # Space
   20) if test "x$(stack_peek_name_hex parse)" != 'x'; then
         stack_push_name_hex_unit parse ''
       fi;;
   # identifier character
   *) stack_pop_name_result_unit parse current
      stack_push_name_hex_unit parse "$current$c";;
  esac
done

while test "x$(stack_len_name_int parse)" != 'x0'; do
  stack_pop_name_result_unit parse tmp
  echo "$tmp 0a"
done | tac | xxd -ps -r
)
