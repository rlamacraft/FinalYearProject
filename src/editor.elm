port module Editor exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick, onInput)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL
type alias Model =
  { text : String }

init : (Model, Cmd Msg)
init =
  (Model "", Cmd.none)


-- UPDATE
type Msg = SendTextOut | GetTextBack String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SendTextOut ->
      ( model, textOut "foo" )
    GetTextBack newText ->
      ( { model | text = newText }, Cmd.none)


-- PORTS
port textOut : String -> Cmd msg
port textIn : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  textIn GetTextBack


-- VIEW
view : Model -> Html Msg
view model =
    div [] [
      button [onClick SendTextOut] [text "Send Message!"],
      text model.text
    ]
