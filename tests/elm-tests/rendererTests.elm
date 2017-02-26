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
    stringStatementContentHtml =  Html.span [ attribute "slot" "content_0" ] [ Html.span [] [text stringContent] ]
    stringStatementRawContentHtml = Html.span [ attribute "slot" "content_raw" ] [ text stringContent ]
    command = Statement.Command commandName [ stringStatementContent ] stringContent
    commandHtml state = Html.node ("pres-" ++ commandName) [ attribute "displaying" state ] [ stringStatementRawContentHtml, stringStatementContentHtml ]
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
    -- statements
    stringContent           = "foo"
    stringContentStatement  = Statement.StringStatement stringContent
    childName               = "child"
    child                   = Statement.Command childName [stringContentStatement] stringContent
    parentName              = "parent"
    singleParentRawContent  = "\\" ++ childName ++ "{" ++ stringContent ++ "}"
    twoParentRawContent     = singleParentRawContent ++ singleParentRawContent
    parent                  = Statement.Command parentName [child] singleParentRawContent

    -- html generating helpers and templates
    slotTemplate slotIndex children = Html.span [ attribute "slot" ("content_" ++ toString slotIndex) ] children
    stringContentHtml               = slotTemplate 0 [ Html.span [] [ text stringContent ] ]
    slotRawTemplate content         = Html.span [ attribute "slot" "content_raw"] [ text content ]

    htmlTemplate name state children  = Html.node ("pres-" ++ name) [ attribute "displaying" state ] children
    childHtmlTemplate state slotIndex = slotTemplate slotIndex [ htmlTemplate childName state [ slotRawTemplate stringContent, stringContentHtml ] ]
    parentHtmlTemplate children       = htmlTemplate parentName "child-showing" children

    -- one child
    parentHtml  = parentHtmlTemplate [ slotRawTemplate singleParentRawContent, childHtmlTemplate "showing" 0 ]

    -- multiple children
    multipleChildren        = Statement.Command parentName [child, child] twoParentRawContent
    multipleChildrenHtml_0  = parentHtmlTemplate [ slotRawTemplate twoParentRawContent, childHtmlTemplate "showing" 0, childHtmlTemplate "coming" 1 ]
    multipleChildrenHtml_1  = parentHtmlTemplate [ slotRawTemplate twoParentRawContent, childHtmlTemplate "seen" 0, childHtmlTemplate "showing" 1 ]
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
