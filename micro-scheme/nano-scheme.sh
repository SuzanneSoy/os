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
# b quote next byte in the source
# q quotes its argument
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
# Y symbol         octal
#
# Note: octal strings must not contain any spaces.

h=0
s=0

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

stack_debug()    { for stack_debug_i in `seq $s`; do
		     printf "<%s " $stack_debug_i
		     eval a=\$s$stack_debug_i
		     printf "%s>" $a
		   done
		 printf \\n; }

rlist() {
  heap_sbrk; heap_set $h N _
  rlist_cdr=$h
  eval a=\$s$s
  while test "$a" != M && test $s -ge 0; do
    heap_sbrk; heap_set_pair $h P $a $rlist_cdr
    rlist_cdr=$h
    s=$(($s-1))
    eval a=\$s$s
  done
  if test $s -lt 0; then
    printf 'Parse error: unbalanced parenthesis'\\n
    exit 1
  fi
  eval s$s=$rlist_cdr
}

debug_print() {
  heap_get_type $1
  if test $a = P; then
      if $2; then printf %s ' '; else printf %s '('; fi
      heap_get_val $1
      debug_print $a false
      heap_get_cdr $1
      debug_print $a true
      if $2; then :; else printf %s ')'; fi
  elif test $a = N; then
    if $2; then :; else printf %s '()'; fi
  elif test $a = Y; then
    if $2; then printf %s '.'; fi
    heap_get_val $1
    printf \\$a
    if $2; then printf %s ')'; fi
  else
    if $2; then printf %s '.'; fi
    printf %s $a
    heap_get_val $1
    printf %s $a
    heap_get_cdr $1
    printf %s $a
    if $2; then printf %s ')'; fi
  fi
}

eval_scheme() {
  local callee ptr result
  heap_get_type $1
  if test $a = P; then
      heap_get_val $1
      # TDODO: use a stack
      echo h=$h
      heap_sbrk; heap_set_pair $h P $a $h;
      echo h=$h
      callee=$a
      echo -n callee=
      debug_print $callee false
      echo
      # compute the arguments
      a=P
      heap_get_cdr $1
      ptr=$a
      heap_get_type $ptr
      echo cdr1=$ptr type=$a
      while test "$a" != N; do
        heap_get_val $ptr
        echo val=$a
        eval_scheme $a
        # TODO: push on a stack
        echo h=$h
        heap_sbrk; heap_set_pair $h P $a $h;
        echo h=$h
        result=$a
        echo result=$result
        heap_get_cdr $ptr
        ptr=$a
        heap_get_type $ptr
        echo cdr=$ptr type=$a
        a=N
      done
      # TODO: this assumes that the callee is a symbol.
      heap_get_val $callee
      echo callee====$callee
      echo callee----$a
      case $a in
        # octal for "r"
        162) echo READ
             # fake read (always returns "h", soon to be "hello"!)
             a=150;; # TODO: should be some-input | od -v -A n -t x1 | read -n 1 a
        # octal for "w"
        167) echo WRITE: $result
             printf \\$result >> output;; # TODO: should use octal, \x is not portable.
        *)   echo TODO_OR_ERROR
             a=42;;
      esac
  else
    echo TODO_OR_ERROR
    a=42
  fi
}

main() {
  # printf '(w((lxx)r))' \
  # printf '(r)' \
  printf '(w(r))' \
    | od -v -A n -t o1 \
    | sed -e 's/^ //' \
    | tr ' ' \\n \
    | (while read c; do
	 echo lex:$c
	 case "$c" in
           # octal for "("
	   050)                              s=$(($s+1)); eval s$s=M  ;;
           # octal for ")"
	   051) stack_debug; rlist; stack_debug ;;
	   *)  heap_sbrk; heap_set $h Y $c; s=$(($s+1)); eval s$s=$h ;;
	 esac
       done
       heap_debug
       echo
       to_eval=$h
       heap_sbrk; heap_set $h N _
       eval_scheme $to_eval
       echo
       debug_print $to_eval false)
}

if true; then main; exit $?; fi
