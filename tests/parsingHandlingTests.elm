module ParsingHandlingTests exposing (..)

import ParsingHandling as PH
import Test exposing (..)
import Expect

processStatement : Test
processStatement =
  let
    simpleStringStatement = PH.StringStatement "foo"
    childCommand          = PH.Command "childCommand" [] ""
  in
    describe "Tests for processStatement"
      [ test "Simple String" <|
        \() ->
          PH.processStatement "_string" [] "foo"
            |> Expect.equal simpleStringStatement
      , test "Empty String" <|
        \() ->
          PH.processStatement "_string" [] ""
            |> Expect.equal (PH.StringStatement "")
      , test "Simple Component" <|
        \() ->
          PH.processStatement "componentName" [ simpleStringStatement ] "foo"
            |> Expect.equal (PH.Command "componentName" [ simpleStringStatement ] "foo")
      , test "Empty Component" <|
        \() ->
          PH.processStatement "componentName" [] ""
            |> Expect.equal (PH.Command "componentName" [] "")
      , test "Nested Components" <|
        \() ->
          PH.processStatement "parentComponent" [ childCommand ] ""
            |> Expect.equal (PH.Command "parentComponent" [ childCommand ] "")
      ]
