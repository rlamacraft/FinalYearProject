port module Presenter exposing (..)

import List exposing(map,sum,length,filter)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (id)
import Html.App as App

import PresenterMessages exposing (Msg(..))
import Statement exposing (Statement,leafCommandCount,isRenderableCommand)
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
    renderableStatements = filter Statement.isRenderableCommand model.data
    numOfCommands = sum ( map Statement.leafCommandCount renderableStatements)
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
        Ok newData ->
          ( { model | data = newData }, Cmd.none )
        Err msg ->
          ( model, Cmd.none )
    Restart ->
      ( { model | displayIndex = 0 }, Cmd.none )
    ForwardTransition ->
      ( { model | displayIndex = cycleTransition model}, Cmd.none )


-- PORTS
port parsedData           : (String -> msg) -> Sub msg  -- re-parse and render the presentation with new model
port restartPresentation  : (() -> msg) -> Sub msg      -- render the presentation with display index 0, i.e. from beginning 

subscriptions : Model -> Sub Msg
subscriptions model =
  let
    restartPres () = Restart
  in
    Sub.batch
      [ parsedData Received
      , restartPresentation restartPres
      ]


-- VIEW
view : Model -> Html Msg
view model =
  div [ onClick ForwardTransition, id "background" ] (Renderer.renderStatements model.data model.displayIndex)
