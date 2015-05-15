# `acme-memorandom`

[![Hackage](https://budueba.com/hackage/acme-memorandom)](https://hackage.haskell.org/package/acme-memorandom)

A library for generating random numbers in a memoized manner. Implemented as a
lazy table indexed by serialized [`StdGen`][StdGen]. Monomorphism is used to
facilitate memoization, users should adapt their design to work with random
[`Int`][Int] values only.

[StdGen]: http://hackage.haskell.org/package/random/docs/System-Random.html#t:StdGen
[Int]:    https://hackage.haskell.org/package/base/docs/Prelude.html#t:Int

In a benchmark, the initial generation of 100000 random `Int`s took 10.30
seconds and consumed 2.5 gigabytes of memory. Generating the 100000 `Int`s
again from the same seed only took 2.06 seconds, a 5-fold speedup thanks to
memoization!

Incidentally, generating the 100000 `Int`s with the non-memoized function took
0.12 seconds, but that of course lacks all the benefits of memoization.
