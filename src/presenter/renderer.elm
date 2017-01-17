module Renderer exposing (renderStatements)

import PresenterMessages exposing (Msg)
import ParsingHandling exposing (Statement)
import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing(map,head,tail)

renderSingleStatement : Int -> Statement -> Html Msg
renderSingleStatement displayIndex statement =
  let
    displaying =
      if displayIndex == 0 then "showing" else "hidden"
  in
     case statement of
        ParsingHandling.StringStatement rawContent ->
          span [] [text rawContent]
        ParsingHandling.Command name content rawContent ->
          node ("pres-" ++ name)
            [ attribute "displaying" displaying ]
            [ span
              [attribute "slot" "content"]
              (renderStatements content 0)
            ]

calculateDisplayIndexProgression : Int -> Statement -> Int
calculateDisplayIndexProgression displayIndex statement =
  case statement of
    ParsingHandling.Command name content rawContent ->
      case name of
        "import" -> displayIndex
        _ -> displayIndex - 1
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
