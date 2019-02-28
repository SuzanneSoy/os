#!/bin/sh

# Scheme syntax:
#
# ()lrwqicntfexyz
#
# ( start list
# ) end list
# l lambda
# r read byte
# w write byte
# q quote next byte in the source
# i byte to int
# c cons
# n null
# t true
# f false
# e eq?
# x user variable (shadowing not allowed)
# y user variable (shadowing not allowed)
# z user variable (shadowing not allowed)
# TODO: free, GC roots, alloc, function pointers, …
#
# sh variables:
#
# a   answer
# c   lexer current char
# h   heap_max
# t$i heap_type[$i]
# v$i heap_value[$i]
# d$i heap_cdr[$i]
#
# heap types:
#
# type             v   d
# P pair           ptr ptr
# N null           "_"
# F free cell      ptr
# I integer        int
# Y symbol         hex
# O lexer "(" mark "_"
#
# Note: hex strings must not contain any spaces.

h=0

heap_sbrk()     { h=$(($h+1)); }
heap_get_type() { eval a=\$t$1; }
heap_get_val()  { eval a=\$v$1; }
heap_get_cdr()  { eval a=\$d$1; }
heap_set()      { eval t$1=$2; eval v$1=$3; }
heap_set_pair() { eval t$1=$2; eval v$1=$3; eval d$1=$4; }

heap_debug()    { for heap_debug_i in `seq $h`; do
		    printf %s" " $heap_debug_i
		    heap_get_type $heap_debug_i; printf %s" " $a
		    heap_get_val  $heap_debug_i; printf %s" " $a
		    heap_get_cdr  $heap_debug_i; printf %s\\n $a
		  done }

rlist() {
  rlist_ptr=$h
  heap_sbrk; heap_set $h N _
  rlist_cdr=$h
  heap_get_type $rlist_ptr
  while test $a != O; do
    heap_sbrk; heap_set_pair $h P $rlist_ptr $rlist_cdr
    rlist_cdr=$h
    rlist_ptr=$(($rlist_ptr-1))
    heap_get_type $rlist_ptr
  done
  a=$rlist_cdr
}

main() {
  printf '(lxx)' \
    | od -v -A n -t x1 \
    | sed -e 's/^ //' \
    | tr ' ' \\n \
    | (while read c; do
	 echo lex:$c
	 case "$c" in
	   28) heap_sbrk; heap_set $h O _  ;;
	   29) rlist ;;
	   *)  heap_sbrk; heap_set $h Y $c ;;
	 esac
       done
       heap_debug)
}

if true; then main; exit $?; fi
