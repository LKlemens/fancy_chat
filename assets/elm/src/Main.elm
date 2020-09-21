port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, button, div, form, input, li, text, ul)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Url
import Url.Parser exposing ((</>), Parser, parse)



-- MAIN
-- main : Html


main : Program String Model Msg
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
    | NotFound


routeParser : Parser (String -> a) a
routeParser =
    Url.Parser.string


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


initialModel : String -> Url.Url -> Nav.Key -> Model
initialModel name url key =
    { name = name
    , username = ""
    , msg = ""
    , msgs = []
    , key = key
    , url = url
    }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init name url key =
    ( initialModel name url key, initialCommand )



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
    Decode.field "msg" Decode.string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            ( model, Cmd.none )

        BroadcastCustom message ->
            ( { model | msg = "" }, sendMessage message )

        HandleMsg message ->
            ( { model | msg = message }, Cmd.none )

        HandleLogin username ->
            ( { model | username = username }, Cmd.none )

        ReceiveMsg jsonName ->
            case Decode.decodeValue stringDecoder jsonName of
                Ok user_message ->
                    ( { model | msgs = model.msgs ++ [ user_message ] }, Cmd.none )

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


getName : Url.Url -> String
getName url =
    Maybe.withDefault "" (parse routeParser url)



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
            [ form [ Events.onSubmit (BroadcastCustom model.msg) ]
                [ viewMsgs model.msgs model.name
                , viewInput "input" "write msg" model.msg HandleMsg
                , sendButton model
                ]
            ]
        ]
    }


viewMsgs : List String -> String -> Html msg
viewMsgs list name =
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
