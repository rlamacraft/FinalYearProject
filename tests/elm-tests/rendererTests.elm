module RendererTests exposing (all)

import Statement exposing (Statement)
import Renderer exposing (renderStatements)
import Html exposing (..)
import Html.Attributes exposing (..)
import Test exposing (..)
import Expect

all : Test
all =
  describe "All Renderer Tests"
    [ renderStatements
    ]

renderStatements : Test
renderStatements =
  describe "Tests for renderStatements"
    [ renderStringStatement "foo"
    , renderSingleCommand
    , renderDisplayingParent
    ]

renderStringStatement : String -> Test
renderStringStatement string =
  let
    stringStatement = Statement.StringStatement string
    stringStatementHtml = Html.span [] [text string]
  in
    test "String Statement" <|
      \() ->
        Renderer.renderStatements [ stringStatement ] 0
          |> Expect.equal [ stringStatementHtml ]

renderSingleCommand : Test
renderSingleCommand =
  let
    stringContent = "foo"
    commandName = "command"
    stringStatementContent = Statement.StringStatement stringContent
    stringStatementContentHtml =  Html.span [] [text stringContent]
    command = Statement.Command commandName [ stringStatementContent ] stringContent
    commandHtml state = Html.node ("pres-" ++ commandName) [ attribute "displaying" state ] [ Html.span [ attribute "slot" "content_0" ] [ stringStatementContentHtml ] ]
  in
    describe "Rendering Single Command Tests"
      [ test "Command - Currently Showing" <|
        \() ->
          Renderer.renderStatements [ command ] 0
            |> Expect.equal [ commandHtml "showing" ]
      , test "Command - Showing in the future" <|
        \() ->
          Renderer.renderStatements [ command ] -1
            |> Expect.equal [ commandHtml "coming" ]
      , test "Command - Seen" <|
        \() ->
          Renderer.renderStatements [ command ] 1
            |> Expect.equal [ commandHtml "seen" ]
      ]

renderDisplayingParent : Test
renderDisplayingParent =
  let
    stringContent = "foo"
    childName = "child"
    parentName = "parent"
    slotTemplate slotIndex children = Html.span [ attribute "slot" ("content_" ++ toString slotIndex) ] children
    stringContentStatement = Statement.StringStatement stringContent
    child = Statement.Command childName [stringContentStatement] stringContent
    parentContent = "\\" ++ childName ++ "{" ++ stringContent ++ "}"
    parent = Statement.Command parentName [child] parentContent
    stringContentHtml = slotTemplate 0 <| [ Html.span [] [ text stringContent ] ]
    htmlTemplate name state children = Html.node ("pres-" ++ name) [ attribute "displaying" state ] children
    childHtmlTemplate state slotIndex = htmlTemplate childName state [ stringContentHtml ]
    childHtml = childHtmlTemplate "showing" 0
    parentHtmlTemplate children = htmlTemplate parentName "child-showing" children
    parentHtml = parentHtmlTemplate <| [ slotTemplate 0 [ childHtml ] ]
    multipleChildren = Statement.Command parentName [child, child] (parentContent ++ parentContent)
    multipleChildrenHtml_0 = parentHtmlTemplate [ slotTemplate 0 <| [ childHtmlTemplate "showing" 0 ], slotTemplate 1 <| [ childHtmlTemplate "coming"  1 ] ]
    multipleChildrenHtml_1 = parentHtmlTemplate [ slotTemplate 0 <| [ childHtmlTemplate "seen"    0 ], slotTemplate 1 <| [ childHtmlTemplate "showing" 1 ] ]
  in
    describe "Rendering Parent Command Tests"
      [ test "Command - One Child Showing" <|
        \() ->
          Renderer.renderStatements [ parent ] 0
            |> Expect.equal [ parentHtml ]
      , test "Command - One Child Showing, One Child Coming" <|
        \() ->
          Renderer.renderStatements [ multipleChildren ] 0
            |> Expect.equal [ multipleChildrenHtml_0]
      , test "Command - One Child Seen, One Child Showing" <|
        \() ->
          Renderer.renderStatements [ multipleChildren ] 1
            |> Expect.equal [ multipleChildrenHtml_1 ]
      ]
