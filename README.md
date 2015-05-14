# `acme-memorandom`

[![Hackage](https://budueba.com/hackage/acme-memorandom)](https://hackage.haskell.org/package/acme-memorandom)

A library for generating random numbers in a memoized manner. Implemented as a
lazy table indexed by serialized [`StdGen`][StdGen]. Monomorphism is used to
facilitate memoization, users should adapt their design to work with random
[`Int`][Int] values only.

[StdGen]: http://hackage.haskell.org/package/random/docs/System-Random.html#t:StdGen
[Int]:    https://hackage.haskell.org/package/base/docs/Prelude.html#t:Int
