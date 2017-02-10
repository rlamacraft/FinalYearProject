module StatementTests exposing (all)

import Statement exposing (Statement)
import Test exposing (..)
import Expect

all : Test
all =
  describe "All Statement Tests"
    [ isRenderableCommand
    ]

isRenderableCommand : Test
isRenderableCommand =
  let
    stringStatement = Statement.StringStatement "foo"
    hiddenCommand = Statement.Command "hidden" [Statement.StringStatement "hidden message"] "hidden message"
    genericCommand = Statement.Command "foo" [Statement.StringStatement "foo"] "foo"
  in
    describe "Tests for isRenderable"
      [ test "String Statement" <|
        \() ->
          Statement.isRenderableCommand stringStatement
            |> Expect.equal False
      , test "Hidden Command" <|
        \() ->
          Statement.isRenderableCommand hiddenCommand
            |> Expect.equal False
      , test "Generic Command" <|
        \() ->
          Statement.isRenderableCommand genericCommand
            |> Expect.equal True
      ]
