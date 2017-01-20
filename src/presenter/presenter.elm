port module Presenter exposing (..)

import List exposing(map,sum,length)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.App as App

import PresenterMessages exposing (Msg(..))
import Statement exposing (Statement,numOfChildCommands)
import ParsingHandling exposing (buildStatementTree)
import Renderer exposing (renderStatements)

main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL
type alias Model =
  { data : List Statement
  , displayIndex : Int }

init : (Model, Cmd Msg)
init =
  (Model [] 0, Cmd.none)


-- UPDATE

cycleTransition : Model -> Int
cycleTransition model =
  let
    numOfStatements = length model.data + sum ( map Statement.numOfChildCommands model.data)
  in
    if model.displayIndex == numOfStatements - 1 then
      0
    else
      model.displayIndex + 1

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Received newData ->
      case buildStatementTree newData of
        Err msg ->
          Debug.log msg
          ( model, Cmd.none )
        Ok newData ->
          ( { model | data = newData, displayIndex = 0}, Cmd.none )
    ForwardTransition ->
      ( { model | displayIndex = cycleTransition model}, Cmd.none )


-- PORTS
port parsedData : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  parsedData Received


-- VIEW
view : Model -> Html Msg
view model =
  div [ onClick ForwardTransition ] (Renderer.renderStatements model.data model.displayIndex)
