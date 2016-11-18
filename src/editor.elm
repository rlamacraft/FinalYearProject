port module Editor exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)

import ParsingHandling exposing (Statement, buildStatementTree)

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
  , text : String }

init : (Model, Cmd Msg)
init =
  (Model [] "", Cmd.none)

-- UPDATE
type Msg = ParseText | UpdateInputText String | OpenFile | NewWindow

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateInputText newText ->
      ( { model | text = newText }, Cmd.none )
    ParseText ->
      ( model, parseText model.text )
    OpenFile ->
      ( model, requestFile () )
    NewWindow ->
      ( model, createWindow () )

-- PORTS
port parseText : String -> Cmd msg
port requestFile : () -> Cmd msg
port createWindow: () -> Cmd msg

port parsedData : (String -> msg) -> Sub msg
port fileData : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  fileData UpdateInputText

-- VIEW
view : Model -> Html Msg
view model =
  div [ class "container" ]
    [ div [ class "controls" ]
      [ button [ onClick NewWindow ] [text "new"]
      , button [ onClick OpenFile ] [text "open"]
      , button [] [text "save"]
      , button [ onClick ParseText, class "btnPresent"] [text "present"]
      ]
    , textarea [ onInput UpdateInputText, value model.text ] []
    ]
