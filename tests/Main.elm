port module Main exposing (..)

import ParsingHandlingTests as PHtests
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)


main : Program Value
main =
    run emit PHtests.processStatement


port emit : ( String, Value ) -> Cmd msg
