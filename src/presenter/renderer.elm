module Renderer exposing (renderStatements)

import PresenterMessages exposing (Msg)
import Statement exposing (Statement,numOfChildCommands)
import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing(map,head,tail,sum)

renderSingleStatement : Int -> Statement -> Html Msg
renderSingleStatement displayIndex statement =
  let
    numOfDescendents = Statement.numOfChildCommands statement
    isALeafNode      = numOfDescendents == 0
    isAParentNode    = numOfDescendents > 0
    displaying =
      if (isAParentNode && displayIndex < numOfDescendents) || (isALeafNode && displayIndex == 0) then
        "showing" else "hidden"
  in
     case statement of
        Statement.StringStatement rawContent ->
          span [] [text rawContent]
        Statement.Command name content rawContent ->
          node ("pres-" ++ name)
            [ attribute "displaying" displaying ]
            [ span
              [attribute "slot" "content"]
              (renderStatements content displayIndex)
            ]

calculateDisplayIndexProgression : Int -> Statement -> Int
calculateDisplayIndexProgression displayIndex statement =
  case statement of
    Statement.Command name content rawContent ->
      case name of
        "import" -> displayIndex
        _ -> displayIndex - (Statement.numOfChildCommands statement + 1)
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
