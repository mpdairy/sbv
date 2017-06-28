-----------------------------------------------------------------------------
-- |
-- Module      :  TestSuite.Basics.IteTest
-- Copyright   :  (c) Levent Erkok
-- License     :  BSD3
-- Maintainer  :  erkokl@gmail.com
-- Stability   :  experimental
--
-- Test various incarnations of laziness in ite
-----------------------------------------------------------------------------

module TestSuite.Basics.IteTest(tests)  where

import Data.SBV

import SBVTest

chk1 :: (SBool -> SBool -> SBool -> SBool) -> SWord8 -> SBool
chk1 cond x = cond (x .== x) true undefined

chk2 :: (SBool -> [SBool] -> [SBool] -> [SBool]) -> SWord8 -> SBool
chk2 cond x = head (cond (x .== x) [true] [undefined])

chk3 :: (SBool -> (SBool, SBool) -> (SBool, SBool)  -> (SBool, SBool)) -> SWord8 -> SBool
chk3 cond x = fst (cond (x .== x) (true, undefined::SBool) (undefined, undefined))

-- Test suite
tests :: TestTree
tests =
  testGroup "Basics.Ite"
    [ goldenVsStringShow "iteTest1" (rs (chk1 ite))
    , goldenVsStringShow "iteTest2" (rs (chk2 ite))
    , goldenVsStringShow "iteTest3" (rs (chk3 ite))
    , testCase "iteTest4" (assertIsThm (chk1 iteLazy))
    , testCase "iteTest5" (assertIsThm (chk2 iteLazy))
    , testCase "iteTest6" (assertIsThm (chk3 iteLazy))
    ]
 where rs f = runSAT $ forAll ["x"] f
