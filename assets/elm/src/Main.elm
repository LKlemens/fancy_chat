port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (placeholder)
import Html.Events
import Json.Decode as Decode
import Json.Encode as Encode



-- MAIN
-- main : Html


main =
    Browser.element
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }



-- PORTS


port sendMessage : String -> Cmd msg


port messageReceiver : (String -> msg) -> Sub msg



-- MODEL


type alias Model =
    { name : String
    }


initialCommand : Cmd Msg
initialCommand =
    Cmd.none


initialModel : Model
initialModel =
    { name = "popo"
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, initialCommand )



-- UPDATE


type Msg
    = Init
    | BroadcastCustom String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            ( initialModel, Cmd.none )

        BroadcastCustom name ->
            ( { model | name = name }, sendMessage name )



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ text model.name
        , viewBroadcastButton model
        ]


viewBroadcastButton : Model -> Html Msg
viewBroadcastButton model =
    let
        broadcastEvent =
            model.name
                |> BroadcastCustom
                |> Html.Events.onClick
    in
    button
        [ broadcastEvent
        , Html.Attributes.class "button"
        ]
        [ text "Broadcast Over Socket" ]
