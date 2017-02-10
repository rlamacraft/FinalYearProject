module StatementTests exposing (all)

import Statement exposing (Statement)
import Test exposing (..)
import Expect

all : Test
all =
  describe "All Statement Tests"
    [ isRenderableCommand
    , leafCommandCount
    , hasNoCommandChildren
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

leafCommandCount : Test
leafCommandCount =
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
          Statement.leafCommandCount stringStatement
            |> Expect.equal 0
      , test "Hidden Statement" <|
        \() ->
          Statement.leafCommandCount hiddenCommand
            |> Expect.equal 0
      , test "No Descendents that are Commands" <|
        \() ->
          Statement.leafCommandCount noCommandDescendents
            |> Expect.equal 1
      , test "One Descendent that is a Command" <|
        \() ->
          Statement.leafCommandCount oneCommandDescendent
            |> Expect.equal 1
      , test "Two Descendents that are Commands" <|
        \() ->
          Statement.leafCommandCount twoCommandDescendents
            |> Expect.equal 2
      , test "Parent of a Command that has One Descendent that is a Command" <|
        \() ->
          Statement.leafCommandCount grandparentOfLeaf
            |> Expect.equal 1
      ]

hasNoCommandChildren : Test
hasNoCommandChildren =
  let
    stringStatement = Statement.StringStatement "foo"
    simpleCommand = Statement.Command "child" [ stringStatement ] "foo"
    parentCommand = Statement.Command "parent" [ simpleCommand ] "\\child{foo}"
    mixedParentCommand = Statement.Command "mixed" [ simpleCommand, stringStatement ] "\\child{foo}\nfoo"
  in
    describe "Tests for hasNoCommandChildren"
      [ test "String Statement" <|
        \() ->
          Statement.hasNoCommandChildren stringStatement
            |> Expect.equal True
      , test "Simple Command" <|
        \() ->
          Statement.hasNoCommandChildren simpleCommand
            |> Expect.equal True
      , test "Parent Command" <|
        \() ->
          Statement.hasNoCommandChildren parentCommand
            |> Expect.equal False
      , test "Mixed Parent Command" <|
        \() ->
          Statement.hasNoCommandChildren mixedParentCommand
            |> Expect.equal False
      ]
