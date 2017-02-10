port module Main exposing (..)

import ParsingHandlingTests exposing (all)
import StatementTests exposing (all)
import RendererTests exposing (all)

import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)
import Test exposing (describe, Test)
import List

all : Test
all =
  describe "all imported test"
    [ ParsingHandlingTests.all
    , StatementTests.all
    , RendererTests.all
    ]

main : Program Value
main =
  run emit all


port emit : ( String, Value ) -> Cmd msg
