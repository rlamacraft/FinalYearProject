module Renderer exposing (renderStatements)

import PresenterMessages exposing (Msg)
import Statement exposing (Statement,numOfLeafCommandDescendents)
import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing(map,head,tail,sum)

wrapInContentSpans : List (Html Msg) -> Int -> List (Html Msg)
wrapInContentSpans renderedStatements slotIndex =
  let
    wrapper = span [attribute "slot" ("content_" ++ toString slotIndex)]
  in
    case List.head renderedStatements of
      Just head ->
        case List.tail renderedStatements of
          Just tail ->
            wrapper [head] :: wrapInContentSpans tail (slotIndex + 1)
          Nothing ->
            [wrapper [head]]
      Nothing ->
        []

renderSingleStatement : Int -> Statement -> Html Msg
renderSingleStatement displayIndex statement =
  let
    numOfLeafCommandDescendents = Statement.numOfLeafCommandDescendents statement
    isALeafNode      = numOfLeafCommandDescendents == 1
    isAParentNode    = numOfLeafCommandDescendents > 1
    displayingState = if displayIndex > 0 then "seen" else if displayIndex < 0 then "coming" else "showing"
    displaying =
      if (isAParentNode && displayIndex < numOfLeafCommandDescendents && displayIndex >= 0) then
        "child-showing"
      else if (isALeafNode) then
        displayingState
      else
        "hidden"
  in
    case statement of
      Statement.StringStatement rawContent ->
        span [] [text rawContent]
      Statement.Command name content rawContent ->
        node ("pres-" ++ name)
          [ attribute "displaying" displaying ]
          (wrapInContentSpans (renderStatements content displayIndex) 0)

calculateDisplayIndexProgression : Int -> Statement -> Int
calculateDisplayIndexProgression displayIndex statement =
  case statement of
    Statement.Command name content rawContent ->
      case name of
        "hidden" -> displayIndex
        _ -> displayIndex - (Statement.numOfLeafCommandDescendents statement)
    _ -> displayIndex

renderListHead : Statement -> Maybe (List Statement) -> Int -> List (Html Msg)
renderListHead headStatement tailStatements displayIndex =
  let
    renderedStatement = renderSingleStatement displayIndex headStatement
    nextDisplayIndex = calculateDisplayIndexProgression displayIndex headStatement
  in
    case tailStatements of
      Just theTail ->
        renderedStatement :: renderStatements theTail nextDisplayIndex
      Nothing ->
        renderedStatement :: renderStatements [] nextDisplayIndex

renderStatements : List Statement -> Int -> List (Html Msg)
renderStatements statements displayIndex =
  case (head statements) of
    Just theHead ->
      renderListHead theHead (tail statements) displayIndex
    Nothing ->
      []
