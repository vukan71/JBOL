module {
    name: "word",
    description: "Generic operations on strings and arrays",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/types";

########################################################################
# Types used in declarations:
#   WORD: [a]^string
#   SYMBOL: singleton WORD

########################################################################
# Generic operations on strings and arrays

# Word w:                       [...] or "..."
# Empty word:                   [] or ""
# Concatenate:                  w + u
# Length of w:                  w|length
# Alphabet of w (arrays):       w|unique
# Alphabet of w (strings):      (w/"")|unique|add
# Reverse of w (arrays):        w|reverse
# Reverse of w (strings):       w|explode|reverse|implode

# Rotate in both directions
def rotate($n): #:: WORD|(number) => WORD
    .[$n:] + .[:$n]
;
def rotate: #:: WORD => WORD
    .[1:] + .[:1]
;

# Number of u's in w
def count($u): #:: WORD|(WORD) => number
    indices($u) | length
;

# Generic reverse
def mirror: #:: WORD => WORD
    if isstring
    then explode|reverse|implode
    else reverse
    end
;

########################################################################
# Match one word

# Matches u at the beggining of w?
# DUPLICATED at scanner.jq!
def factor($u): #:: WORD|(WORD) => ?number
    ($u|length) as $j
    | select($j <= length and .[0:$j] == $u)
    | $j
;

# Prefix?
def prefix($u): #:: WORD|(WORD) => boolean
    succeeds(factor($u))
;

# Suffix?
def suffix($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | $j == 0 or $j <= length and .[-$j:] == $u
;

# Proper prefix?
def pprefix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and prefix($u)
;

# Proper suffix?
def psuffix($u): #:: WORD|(WORD) => boolean
    length > ($u|length) and suffix($u)
;

# Proper factor?
def pfactor($u): #:: WORD|(WORD) => boolean
    ($u|length) as $j
    | 0 < $j and $j < length and contains($u)
;

########################################################################
# Word sequences

# Sets of prefixes (without the empty word)
def prefixes: #:: WORD => *WORD
    range(1;length+1) as $i
    | .[:$i]
;

# Sets of suffixes (without the empty word)
def suffixes: #:: WORD => *WORD
    range(length-1;-1;-1) as $i
    | .[$i:]
;

# Sets of factors, (without the empty word)
def factors: #:: WORD => *WORD
# length order:
    range(1;length+1) as $j
    | range(length-$j+1) as $i
    | .[$i:$i+$j]
# different order:
#   range(length+1) as $j
#   | range($j+1; length+1) as $i
#   | .[$j:$i]
;

# Fibbonacci strings
# fibstr("a"; "b") => "a","b","ab","bab","abbab"…
def fibstr($w; $u): #:: (WORD;WORD) => +WORD
    [$w,$u]
    | iterate([.[-1], .[-2]+.[-1]])
    | .[-2]
;

########################################################################
# Word iteration

# Product, catenate: w + u

# Generates wⁿ (one word: w concatenated n times)
def power($n): #:: WORD|(number) => WORD
# assert $n >= 0
    . as $word
    | if isstring
    then if $n == 0 then "" else . * $n end
    else reduce range($n) as $_ ([]; . + $word)
    end
;

# Generates w*: w⁰ ∪ w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
def star: #:: WORD => +WORD
    . as $word
    | if isstring then "" else [] end
    | iterate(. + $word)
;

# Generates w⁺: w¹ ∪ w² ∪ w³ ∪ w⁴ ∪ w⁵ ∪ w⁶ ∪ w⁷ ∪ w⁸ ∪ w⁹…
def plus: #:: WORD => +WORD
    . as $word
    | iterate(. + $word)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
