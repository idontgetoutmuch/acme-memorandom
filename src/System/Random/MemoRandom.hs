{-# LANGUAGE CPP #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

-- |
-- Module      : Systen.Random.MemoRandom
-- Description : Memoized random number generation
-- Copyright   : © 2015 Johan Kiviniemi
-- License     : MIT
-- Maintainer  : Johan Kiviniemi <devel@johan.kiviniemi.name>
-- Stability   : provisional
-- Portability : CPP, TypeFamilies, TypeOperators
--
-- A library for generating random numbers in a memoized manner. Implemented as
-- a lazy table indexed by serialized 'StdGen'. Monomorphism is used to
-- facilitate memoization, users should adapt their design to work with random
-- 'Int' values only.
module System.Random.MemoRandom
  ( randomR'
  , random'
  , randomRs'
  , randoms'
  , randomRIO'
  , randomIO'
  ) where

import Data.MemoTrie
import System.Random

#ifdef __GLASGOW_HASKELL__
import GHC.Exts (build)
#else
-- | A dummy variant of build without fusion.
{-# INLINE build #-}
build :: ((a -> [a] -> [a]) -> [a] -> [a]) -> [a]
build g = g (:) []
#endif

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

-- | A memoized variant of 'randomRs'.
{-# INLINE randomRs' #-}
randomRs' :: (Int, Int) -> StdGen -> [Int]
randomRs' ival g = build (\cons _nil -> buildRandoms cons (randomR' ival) g)

-- | A memoized variant of 'randoms'.
{-# INLINE randoms' #-}
randoms' :: StdGen -> [Int]
randoms' g = build (\cons _nil -> buildRandoms cons random' g)

-- | A memoized variant of 'randomRIO'.
randomRIO' :: (Int, Int) -> IO Int
randomRIO' ival = getStdRandom (randomR' ival)

-- | A memoized variant of 'randomIO'.
randomIO' :: IO Int
randomIO' = getStdRandom random'

-- | Produce an infinite list-equivalent of random values.
--
-- Copied from System.Random verbatim (but originally written by the author of
-- MemoRandom, commit 4695ffa).
{-# INLINE buildRandoms #-}
buildRandoms :: RandomGen g
             => (a -> as -> as)  -- ^ E.g. '(:)' but subject to fusion
             -> (g -> (a,g))     -- ^ E.g. 'random'
             -> g                -- ^ A 'RandomGen' instance
             -> as
buildRandoms cons rand = go
  where
    -- The seq fixes part of #4218 and also makes fused Core simpler.
    go g = x `seq` (x `cons` go g') where (x,g') = rand g
