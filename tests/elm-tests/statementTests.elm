module StatementTests exposing (all)

import Statement exposing (Statement)
import Test exposing (..)
import Expect

all : Test
all =
  describe "All Statement Tests"
    [ isRenderableCommand
    , numOfLeafCommandDescendents
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

numOfLeafCommandDescendents : Test
numOfLeafCommandDescendents =
  let
    stringStatement       = Statement.StringStatement "foo"
    hiddenCommand         = Statement.Command "hidden" [Statement.StringStatement "hidden message"] "hidden message"
    noCommandDescendents  = Statement.Command "leaf" [stringStatement] "foo"
    oneCommandDescendent  = Statement.Command "parent" [noCommandDescendents] "\\leaf{foo}"
    twoCommandDescendents = Statement.Command "parent" [noCommandDescendents, noCommandDescendents] "\\leaf{foo}\n\\leaf{foo}"
    grandparentOfLeaf     = Statement.Command "grandparent" [oneCommandDescendent] "\\parent{\\leaf{foo}}"
  in
    describe "Tests for numOfLeafCommandDescendents"
      [ test "String Statement" <|
        \() ->
          Statement.numOfLeafCommandDescendents stringStatement
            |> Expect.equal 0
      , test "Hidden Statement" <|
        \() ->
          Statement.numOfLeafCommandDescendents hiddenCommand
            |> Expect.equal 0
      , test "No Descendents that are Commands" <|
        \() ->
          Statement.numOfLeafCommandDescendents noCommandDescendents
            |> Expect.equal 1
      , test "One Descendent that is a Command" <|
        \() ->
          Statement.numOfLeafCommandDescendents oneCommandDescendent
            |> Expect.equal 1
      , test "Two Descendent that is a Command" <|
        \() ->
          Statement.numOfLeafCommandDescendents twoCommandDescendents
            |> Expect.equal 2
      , test "Parent of a Command that has One Descendent that is a Command" <|
        \() ->
          Statement.numOfLeafCommandDescendents grandparentOfLeaf
            |> Expect.equal 1
      ]
