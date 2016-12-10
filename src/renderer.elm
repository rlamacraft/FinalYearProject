module Renderer exposing (render)

import PresenterMessages exposing (Msg)
import ParsingHandling exposing (Statement)
import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing(map)

renderCommand : String -> (List Statement) -> String -> Html Msg
renderCommand name content rawContent =
  node ("pres-" ++ name) [] [ span [attribute "slot" "content"] (render content)]

renderStatement : Statement -> Html Msg
renderStatement statement =
  case statement of
    ParsingHandling.StringStatement rawContent ->
      span [] [text rawContent]
    ParsingHandling.Command name content rawContent ->
      renderCommand name content rawContent

render : (List Statement) -> (List (Html Msg))
render statements =
  List.map renderStatement statements
