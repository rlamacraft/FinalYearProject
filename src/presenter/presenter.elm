port module Presenter exposing (..)

import List exposing(map,sum,length,filter)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (id)
import Html.App as App

import PresenterMessages exposing (Msg(..))
import Statement exposing (Statement,numOfLeafCommandDescendents,isRenderable)
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
    renderableStatements = filter Statement.isRenderable model.data
    numOfCommands = sum ( map Statement.numOfLeafCommandDescendents renderableStatements)
  in
    if model.displayIndex == numOfCommands - 1 then
      0
    else
      model.displayIndex + 1

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Received newData ->
      case buildStatementTree newData of
        Err msg ->
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
  div [ onClick ForwardTransition, id "background" ] (Renderer.renderStatements model.data model.displayIndex)
