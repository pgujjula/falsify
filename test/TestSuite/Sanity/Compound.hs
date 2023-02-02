module TestSuite.Sanity.Compound (tests) where

import Data.List.NonEmpty (NonEmpty((:|)), nub)
import Test.Tasty
import Test.Tasty.HUnit

import Test.Falsify.Generator (Gen)

import qualified Test.Falsify.Generator  as Gen
import qualified Test.Falsify.Range      as Range
import qualified Test.Falsify.SampleTree as SampleTree

import TestSuite.Util.Predicates

tests :: TestTree
tests = testGroup "TestSuite.Sanity.Compound" [
      testCase "list" test_list
    ]

test_list :: Assertion
test_list = do
    -- Note that [6, 4] is indeed the minimal counter-example to a sorted list,
    -- when the elements are drawn from the range [0, 10] with origin 5, and
    -- filtered for even numbers.
    --
    -- TODO: This is quite slow, I think primarily due to the precision of the
    -- 'Word64' used for fractions. We should make this configurable.
    let shrinkHistory = [4,0,0,2,6,2,10,4] :| [
            [0,0,2,6,2,10,4]
          , [0,2,6,2,10,4]
          , [2,6,2,10,4]
          , [6,2,10,4]
          , [2,10,4]
          , [10,4]
          , [8,4]
          , [6,4]
          ]
    assertEqual "shrink" shrinkHistory $
      nub $ Gen.shrink (not . prop) gen (SampleTree.fromSeed 0)
  where
    gen :: Gen [Word]
    gen = filter even <$>
            Gen.list (10, 20) (Gen.integral $ Range.num (0, 10) 5)

    prop :: [Word] -> Bool
    prop = pairwiseAll (<=)