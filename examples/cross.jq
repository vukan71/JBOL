#!/usr/local/bin/jq -nRrf

# Output all intersections between two words

import "fadado.github.io/word" as word;

def chars:
    (./"")[]
;

def lpad($n):
    (" "*$n) + .
;

# Produces a stream of intersections between two words
def cross($word1; $word2):
    ($word1|word::upto($word2)) as $i |
    ($word2|word::upto($word1[$i:$i+1])) as $j |
    [
        ($word2[0:$j]  | chars | lpad($i)),
        $word1,
        ($word2[$j+1:] | chars | lpad($i))
    ]
;

# Entry point
def main:
    cross("computer"; "center") | (.[], "")
;

main

# vim:ai:sw=4:ts=4:et:syntax=jq
