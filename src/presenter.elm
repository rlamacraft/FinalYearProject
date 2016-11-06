port module Presenter exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick, onInput)

import ParsingHandling exposing (Statement, buildStatementTree)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL
type alias Model =
  { data : List Statement }

init : (Model, Cmd Msg)
init =
  (Model [], Cmd.none)


-- UPDATE
type Msg = Received String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Received newData ->
      case buildStatementTree newData of
        Err msg ->
          Debug.log msg
          ( model, Cmd.none )
        Ok newData ->
          ( { model | data = newData }, Cmd.none )

-- PORTS
port parsedData : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  parsedData Received


-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ text (toString model.data)
    ]
