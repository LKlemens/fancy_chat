port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, button, div, form, input, li, text, ul)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, s, string)



-- MAIN
-- main : Html


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- PORTS


port sendMessage : String -> Cmd msg


port messageReceiver : (Encode.Value -> msg) -> Sub msg



-- MODEL


type Route
    = Name String


routeParser : Parser (String -> a) a
routeParser =
    s "" </> string


type alias Model =
    { name : String
    , username : String
    , msg : String
    , msgs : List String
    , key : Nav.Key
    , url : Url.Url
    }


initialCommand : Cmd Msg
initialCommand =
    Cmd.none


initialModel : Url.Url -> Nav.Key -> Model
initialModel url key =
    { name = ""
    , username = ""
    , msg = ""
    , msgs = []
    , key = key
    , url = url
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel url key, initialCommand )



-- UPDATE


type Msg
    = Init
    | BroadcastCustom String
    | ReceiveMsg Encode.Value
    | HandleLogin String
    | HandleMsg String
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


stringDecoder =
    Decode.field "name" Decode.string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            let
                name =
                    routeParser
            in
            ( model, Cmd.none )

        BroadcastCustom message ->
            ( { model | msgs = model.msgs ++ [ message ] }, sendMessage message )

        HandleMsg message ->
            ( { model | msg = message }, Cmd.none )

        HandleLogin username ->
            ( { model | username = username }, Cmd.none )

        ReceiveMsg jsonName ->
            case Decode.decodeValue stringDecoder jsonName of
                Ok name ->
                    ( { model | name = name }, Cmd.none )

                Err message ->
                    Debug.log ("Error receiving name " ++ Debug.toString message)
                        ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    messageReceiver ReceiveMsg



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "url"
    , body =
        [ div []
            [ form []
                [ viewMsgs model.msgs
                , viewInput "input" "write msg" model.msg HandleMsg
                , sendButton model
                ]
            ]
        ]
    }


viewMsgs : List String -> Html msg
viewMsgs list =
    ul [] (List.map (\m -> li [] [ text m ]) list)


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, Events.onInput toMsg ] []


sendButton : Model -> Html Msg
sendButton model =
    let
        broadcastEvent =
            model.msg
                |> BroadcastCustom
                |> Events.onClick
    in
    button
        [ broadcastEvent
        , type_ "button"
        , Html.Attributes.class "button is-danger"
        ]
        [ text "send" ]
