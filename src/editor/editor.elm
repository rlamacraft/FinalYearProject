port module Editor exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (class, value)

import Statement exposing (Statement(..))

main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL
type SavedToastState = Hidden String | Displaying String -- either Hidden and holds previous msg or showing a msg

type alias Model =
  { data : List Statement
  , text : String
  , savedToast : SavedToastState }

init : (Model, Cmd Msg)
init = (Model [] "" (Hidden ""), Cmd.none)


-- UPDATE
type Msg = UpdateInputText String | ParseText | OpenFile | NewWindow | SaveFile | SavedFileStatus String | HideSavedToast

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    hideSavedToastModel toastState newModel =
      case toastState of
        Hidden oldMsg ->
          ( { newModel | savedToast = Hidden oldMsg }, Cmd.none )
        Displaying currentMsg ->
          ( { newModel | savedToast = Hidden currentMsg }, Cmd.none )
  in
    case msg of
      UpdateInputText newText ->
        hideSavedToastModel model.savedToast { model | text = newText }
      ParseText ->
        ( model, parseText model.text )
      OpenFile ->
        ( model, requestFile () )
      NewWindow ->
        ( model, createWindow () )
      SaveFile ->
        ( model, writeToFile model.text )
      SavedFileStatus status ->
        ( { model | savedToast = Displaying status }, Cmd.none )
      HideSavedToast ->
        hideSavedToastModel model.savedToast model

-- PORTS
port parseText    : String  -> Cmd msg -- Parser and generate the presentation
port requestFile  : ()      -> Cmd msg -- Open file via system dialog
port createWindow : ()      -> Cmd msg -- Create new blank window
port writeToFile  : String  -> Cmd msg -- Save file according to path from previous OpenFile

port fileData       : (String -> msg) -> Sub msg -- Data loaded from file
port present        : (() -> msg) -> Sub msg     -- Request for presenting from App Menu
port saveFile       : (() -> msg) -> Sub msg     -- Request for saving from App Menu
port savedFile      : (String -> msg) -> Sub msg -- status after attempting saving
port hideSavedToast : (() -> msg) -> Sub msg     -- after a duration, the saved toast is hidden
subscriptions : Model -> Sub Msg
subscriptions model =
  let
    parseTextFunc () = ParseText
    saveFileFunc () = SaveFile
    hideSavedToastFunc () = HideSavedToast
  in
    Sub.batch
      [ fileData UpdateInputText
      , present parseTextFunc
      , saveFile saveFileFunc
      , savedFile SavedFileStatus
      , hideSavedToast hideSavedToastFunc
      ]


-- VIEW
materialIcon : String -> Html Msg
materialIcon name =
  i [ class "material-icons" ] [ text name ]

savedToast : SavedToastState -> Html Msg
savedToast state =
  let
    html stateClass msg = div [ class ("toast toast-" ++ stateClass) ] [ text msg ]
  in
    case state of
      Hidden oldMsg -> html "hidden" oldMsg
      Displaying msg -> html "showing" msg

view : Model -> Html Msg
view model =
  div [ class "container" ]
    [ div [ class "controls" ]
      [ button [ onClick NewWindow ] [ materialIcon "add_to_photos" ]
      , button [ onClick OpenFile  ] [ materialIcon "folder_open" ]
      , button [ onClick SaveFile  ] [ materialIcon "save" ]
      , button [ onClick ParseText, class "btnPresent" ] [ materialIcon "ondemand_video" ]
      ]
    , textarea [ onInput UpdateInputText, value model.text ] []
    , div [ class "footer" ]
      [ savedToast model.savedToast ]
    ]
