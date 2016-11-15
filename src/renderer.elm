module Renderer exposing (render)

import PresenterMessages exposing (Msg)
import ParsingHandling exposing (Statement)
import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing(map)

renderCommand : String -> (List Statement) -> String -> Html Msg
renderCommand name content rawContent =
  case name of
    "title" ->
      node "pres-title" [] [ span [attribute "slot" "content"] (render content)]
    _ ->
      div [] (render content)

renderStatement : Statement -> Html Msg
renderStatement statement =
  case statement of
    ParsingHandling.StringStatement rawContent ->
      text rawContent
    ParsingHandling.Command name content rawContent ->
      renderCommand name content rawContent

render : (List Statement) -> (List (Html Msg))
render statements =
  List.map renderStatement statements
