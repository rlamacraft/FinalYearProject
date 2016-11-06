module Tests exposing (..)

import Test exposing (..)
import Expect

example : Test
example =
  describe "a thing"
    [ test "test test" <|
      \() ->
        Expect.equal "foo" "foo"
    ]
