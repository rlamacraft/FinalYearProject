port module Presenter exposing (..)

import List exposing (map,sum,length,filter)
import Char exposing (fromCode)
import String exposing (fromChar)
import Keyboard exposing (presses, KeyCode)

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

cycleTransition : Model -> Int -> Int
cycleTransition model forwardMovement =
  let
    renderableStatements = filter Statement.isRenderableCommand model.data
    numOfCommands = sum ( map Statement.leafCommandCount renderableStatements)
  in
    if model.displayIndex >= numOfCommands - forwardMovement then
      0
    else if model.displayIndex + forwardMovement <= 0 then
      numOfCommands
    else
      model.displayIndex + forwardMovement

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    keyCodeToString = String.fromChar << Char.fromCode
  in
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
        ( { model | displayIndex = cycleTransition model 1 }, Cmd.none )
      BackwardTransition ->
        ( { model | displayIndex = cycleTransition model -1 }, Cmd.none )
      OtherKeyboardPress keycode ->
        Debug.log ("pressed key: " ++ (keyCodeToString keycode))
        ( model, Cmd.none )

-- PORTS
port parsedData           : (String -> msg) -> Sub msg  -- re-parse and render the presentation with new model
port restartPresentation  : (() -> msg) -> Sub msg      -- render the presentation with display index 0, i.e. from beginning

subscriptions : Model -> Sub Msg
subscriptions model =
  let
    restartPres () = Restart
    keyboardPress keycode =
      case keycode of
        93 -> ForwardTransition
        91 -> BackwardTransition
        32 -> ForwardTransition
        _  -> OtherKeyboardPress keycode
  in
    Sub.batch
      [ parsedData Received
      , restartPresentation restartPres
      , presses keyboardPress
      ]


-- VIEW
view : Model -> Html Msg
view model =
  div [ onClick ForwardTransition, id "background" ] (Renderer.renderStatements model.data model.displayIndex)
