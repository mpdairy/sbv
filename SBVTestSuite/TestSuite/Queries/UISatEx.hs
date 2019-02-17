-----------------------------------------------------------------------------
-- |
-- Module    : TestSuite.Queries.UISatEx
-- Copyright : (c) Levent Erkok
-- License   : BSD3
-- Maintainer: erkokl@gmail.com
-- Stability : experimental
--
-- Testing uninterpreted function extraction
-----------------------------------------------------------------------------

{-# LANGUAGE OverloadedLists   #-}
{-# LANGUAGE OverloadedStrings #-}

module TestSuite.Queries.UISatEx where

import Utils.SBVTestFramework

-- Test suite
tests :: TestTree
tests =
  testGroup "Queries.UISatEx"
    [ goldenCapturedIO "query_uisatex" testQuery
    ]

testQuery :: FilePath -> IO ()
testQuery rf = do r <- satWith defaultSMTCfg{verbose=True, redirectVerbose=Just rf} core
                  appendFile rf ("\n FINAL:\n" ++ show r ++ "\nDONE!\n")

q1 :: SInteger -> SInteger
q1 = uninterpret "q1"

q2 :: SBool -> SInteger -> SInteger
q2 = uninterpret "q2"

q3 :: SFloat -> SBool -> SInteger -> SFloat
q3 = uninterpret "q3"

q4 :: SChar -> SString -> SFloat
q4 = uninterpret "q4"

q5 :: SList Integer -> SList Float -> SInteger
q5 = uninterpret "q5"

core :: Goal
core = do x <- sInteger_
          constrain $ q1 2    .== 12
          constrain $ q1 3    .== 75
          constrain $ q1 (-3) .== 9
          constrain $ q1 x    .== x+1

          constrain $ q2 sTrue 3   .== 5
          constrain $ q2 sFalse 7  .== 6
          constrain $ q2 sFalse 12 .== 3

          constrain $ q3 8.6 sTrue  12  .== 8.6
          constrain $ fpIsNegativeZero $ q3 9.6 sTrue  121
          constrain $ q3 9.6 sFalse 8   .== 1/0

          constrain $ q4 (literal 'c') "hey" .== 78
          constrain $ q4 (literal 'c') "tey" .== 92
          constrain $ q4 (literal 'r') "foo" .== 3.5

          constrain $ q5 [1,2,3] [8.2, 3] .== 7
          constrain $ q5 [9,5]   [8.2, 9] .== 21
          constrain $ q5 [5]     [8.2, 0] .== 210

{-
qCore :: IO ()
qCore = runSMTWith z3{verbose=True} $ do
          core
          let q6 :: SInteger -> SBool
              q6 = uninterpret "q6"
          constrain $ q6 0 .=> q6 0
          query $ do ensureSat
                     qv1 <- getFunction q1
                     qv2 <- getFunction q2
                     qv3 <- getFunction q3
                     qv4 <- getFunction q4
                     qv5 <- getFunction q5
                     qv6 <- getFunction q6
                     return (qv1, qv2, qv3, qv4, qv5, qv6)
                     -}