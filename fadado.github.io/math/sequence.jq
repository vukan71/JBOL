module {
    name: "math/sequence",
    description: "Mathematical sequences",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

include "fadado.github.io/prelude";
include "fadado.github.io/math";

########################################################################
# Apply functions to ℕ

# fₙ fₙ₊₁ fₙ₊₂ fₙ₊₃ fₙ₊₄ fₙ₊₅ fₙ₊₆ fₙ₊₇ fₙ₊₈ fₙ₊₉…
def tabulate($n; f): #:: (number;number->a) => *a
#   $n | iterate(.+1) | f
    def r: f , (.+1|r);
    $n|r
;
# f₀ f₁ f₂ f₃ f₄ f₅ f₆ f₇ f₈ f₉…
def tabulate(f): #:: (number->a) => *a
#   0 | iterate(.+1) | f
    def r: f , (.+1|r);
    0|r
;

# Arithmetic sequences #################################################

# CF:
#   a(n) = a0+d*n
# RR:
#   a(0) = a
#   a(n) = a(n-1)+d
#
def arithmetic($a; $d): #:: (number;number) => *number
    $a|iterate(. + $d) # range($a; infinite; $d)
;

# CF:
#   a(n) = n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+1
#
def naturals: #:: => *number
    arithmetic(0; 1) # range(0; infinite; 1)
;

def positives: #:: => *number
    arithmetic(1; 1) # range(1; infinite; 1)
;

def negatives: #:: => *number
    arithmetic(-1; -1) # range(-1; 0-infinite; -1)
;

#def seq($a; $d): #:: (number;$number) => *number
#    arithmetic($a; $d) # range($a; infinite; $d)
#;
#def seq($a): #:: (number) => *number
#    arithmetic($a; 1) # range($a; infinite; 1)
#;
#def seq: #:: => *number
#    arithmetic(0; 1) # range(1; infinite; 1)
#;
#def to($m; $n): #:: (number;number) => *number
#    label $out # range($m; $n+1)
#    | arithmetic($m; 1)
#    | when(. > $n; break$out)
#;

# CF:
#   a(n) = 2n+1
# RR:
#   a(0) = 1
#   a(n) = a(n-1)+2
#
def odds: #:: => *number
    arithmetic(1; 2) # range(1; infinite; 2)
;

# CF:
#   a(n) = 2n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+2
#
def evens: #:: => *number
    arithmetic(0; 2) # range(0; infinite; 2)
;

# CF:
#   a(n) = d*n
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+n
#
def multiples($n): #:: (number) => *number
    arithmetic(0; $n) # range(0; infinite; $n)
;
def multiples: #:: number| => *number
    multiples(.) # range(0; infinite; .)
;

# Geometric sequences ##################################################

# CF:
#   a(n) = a*r^n
# RR:
#   a(0) = a
#   a(n) = a(n-1)*r
#
def geometric($a; $r): #:: (number;number) => *number
    $a|iterate(. * $r)
;

# CF:
#   x(n) = r^n
# RR:
#   a(0) = 1
#   a(n) = a(n-1)*r
#
def powers($r): #:: (number) => *number
    geometric(1; $r)
;
def powers: #:: number| => *number
    powers(.)
;

# Other ################################################################

# CF:
#   a(n) = n^2
# RR:
#   a(0) = 0
#   a(n) = a(n-1)+2n-1
#
def squares: #:: => *number
#   tabulate(pow(.; 2))
#   0, foreach positives as $n (0; .+$n+$n-1)
    0, foreach odds as $n (0; .+$n)
;

# CF:
#   a(n) = n^3
# RR:
#   a(0) = 0
#   a(n) = n(a(n-1)+2n-1)
#
def cubes: #:: => *number
#   tabulate(pow(.; 3))
#   0, foreach positives as $n (0; .+$n+$n-1; .*$n)
    foreach squares as $s (-1; .+1; $s*.)
;

#
def reciprocals(g): #:: (a->*number) => *number
    g | 1/.
;

# CF:
#   a(n) = 1/n
#
def harmonic: #:: => *number
    reciprocals(positives)
;

# CF:
#   a(n) = n%m
# RR:
#   a(0) = 0
#   a(n) = 0 if a(n-1)+1 = m else a(n-1)+1
#
def moduli($m): #:: (number) => *number
#   tabulate(. % $m)
#   repeat(range(0; $m))
    0|iterate(. + 1 | when(. == $m; 0))
;
def moduli: #:: number| => *number
    moduli(.)
;

# RR:
#   a(0) = 1
#   a(n) = a(n-1)*n
#
def factorials: #:: => *number
#   1, scan(.[0]*.[1]; 1; positives)
    1, foreach positives as $n (1; . * $n)
;

# RR:
#   a(0) = 0
#   a(n) = a(n-1)+n
#
def triangulars: #:: => *number
    0, foreach positives as $n (0; . + $n)
;

# RR:
#   a(0) = 0
#   a(1) = 1
#   a(n) = a(n-1) + a(n-2)
#
def fibonacci: #:: => *number
    [0,1]
    | iterate([.[-1], .[-1]+.[-2]])
    | .[-2]
#   0, ([0,1] | unfold([.[-1], [.[-1], .[-1]+.[-2]]]))
;

# The famous sieve
#
#def primes: #:: => *number
#    def sieve(g):
#        first(g) as $n
#        | $n, sieve(g|select((. % $n) != 0))
#    ;
#    2, sieve(3|iterate(.+2))
#;

# Very fast alternative!
def primes: #:: => *number
    def isprime(g):
        . as $n
        | label $out
        | g as $p
        | if ($p * $p) > $n
          then true , break$out
          elif ($n % $p) == 0
          then false , break$out
          else empty # next
          end
    ;
    2, (3|iterate(.+2) | select(isprime(primes)))
;

# Number of bits equal to 1 in all naturals (number of ones)
#
# RR:
#   a(0) = 0
#   a(1) = 1
#   a(n+2^k) = a(n) + 1
# and
#   a(2n) = a(n)
#
def leibniz: #:: => *number
    def r(g): (g | .+1) , r(g , (g | .+1));
    0, 1,  r(0 , 1)
;

# Proper divisors ######################################################
#
# unordered
# Inspired in https://rosettacode.org/wiki/Proper_divisors#jq
def divisors($n):
    if $n <= 1
    then empty
    else
        1 ,
        (range(2; 1 + ($n|sqrt|trunc)) as $i
         | select(($n % $i) == 0)
         | $i , (($n / $i) | select(. != $i)))
    end
;

# without 1
def divisors1($n):
    if $n <= 1
    then empty
    else
        range(2; 1 + ($n|sqrt|trunc)) as $i
        | select(($n % $i) == 0)
        | $i , (($n / $i) | select(. != $i))
    end
;

# All integer partitions ###############################################
#
def partition($i): #:: (number) => *[number]
    def choose(a; b): range(a; 1+b);
    #
    def pmax(n; mx):
        if n == 0
        then []
        else
            choose(1; mx) as $m
            | (n-$m) as $k
            | fmin($k; $m) as $b
            | [$m]+pmax($k; $b)
        end
    ;
    pmax($i; $i)
;

# vim:ai:sw=4:ts=4:et:syntax=jq
