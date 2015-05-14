{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

-- |
-- Module      : Systen.Random.MemoRandom
-- Description : Memoized random number generation
-- Copyright   : © 2015 Johan Kiviniemi
-- License     : MIT
-- Maintainer  : Johan Kiviniemi <devel@johan.kiviniemi.name>
-- Stability   : provisional
-- Portability : TypeFamilies, TypeOperators
--
-- A library for generating random numbers in a memoized manner. Implemented as
-- a lazy table indexed by serialized 'StdGen'. Monomorphism is used to
-- facilitate memoization, users should adapt their design to work with random
-- 'Int' values only.
module System.Random.MemoRandom (randomR', random') where

import Data.MemoTrie
import System.Random

newtype StdGen' = StdGen' { unStdGen' :: StdGen }

instance HasTrie StdGen' where
  newtype StdGen' :->: a = StdGenTrie' (String :->: a)
  trie f = StdGenTrie' (trie (f . StdGen' . read))
  untrie (StdGenTrie' t) = untrie t . show . unStdGen'
  enumerate (StdGenTrie' t) = [ (StdGen' (read a), b) | (a,b) <- enumerate t ]

-- | A memoized variant of 'randomR'.
randomR' :: (Int, Int) -> StdGen -> (Int, StdGen)
randomR' ival = memo2 (\ival' -> randomR ival' . unStdGen') ival . StdGen'

-- | A memoized variant of 'random'.
random' :: StdGen -> (Int, StdGen)
random' = memo (random . unStdGen') . StdGen'
