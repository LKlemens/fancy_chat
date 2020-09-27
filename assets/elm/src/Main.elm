port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, form, input, li, p, text, ul)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Set exposing (Set)
import Url
import Url.Parser exposing ((</>), Parser, parse)



-- MAIN
-- main : Html


type alias InitValues =
    { name : String
    , users : List String
    }


options =
    { stopPropagation = True
    , preventDefault = True
    }


main : Program InitValues Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type alias UserMsg =
    { sender : String
    , receiver : String
    , msg : String
    }



-- PORTS


port sendMessage : UserMsg -> Cmd msg


port comeOnline : String -> Cmd msg


port newOnlineUser : (Encode.Value -> msg) -> Sub msg


port messageReceiver : (Encode.Value -> msg) -> Sub msg


port receiveUsers : (Encode.Value -> msg) -> Sub msg



-- MODEL


routeParser : Parser (String -> a) a
routeParser =
    Url.Parser.string


type alias Model =
    { name : String
    , username : String
    , friend : String
    , msg : String
    , msgs : List String
    , key : Nav.Key
    , url : Url.Url
    , usersOnline : Set String
    }


initialCommand : String -> Cmd Msg
initialCommand name =
    comeOnline name


initialModel : InitValues -> Url.Url -> Nav.Key -> Model
initialModel initValues url key =
    let
        list =
            List.filter (\name -> name /= initValues.name) initValues.users
    in
    { name = initValues.name
    , username = ""
    , friend = Maybe.withDefault "" (List.head list)
    , msg = ""
    , msgs = []
    , key = key
    , url = url
    , usersOnline = Set.fromList list
    }


init : InitValues -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init values url key =
    ( initialModel values url key, initialCommand values.name )



-- UPDATE


type Msg
    = Init
    | SendMsg String
    | ReceiveMsg Encode.Value
    | OnlineUsers Encode.Value
    | NewOnlineUser Encode.Value
    | HandleLogin String
    | HandleMsg String
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | UpdateFriend String


stringDecoder name =
    Decode.field name Decode.string


usersDecoder =
    Decode.field "users" (Decode.list Decode.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            ( model, Cmd.none )

        SendMsg message ->
            ( { model | msg = "" }, sendMessage (UserMsg model.name model.friend message) )

        HandleMsg message ->
            ( { model | msg = message }, Cmd.none )

        HandleLogin username ->
            ( { model | username = username }, Cmd.none )

        ReceiveMsg jsonName ->
            case Decode.decodeValue (stringDecoder "msg") jsonName of
                Ok user_message ->
                    ( { model | msgs = model.msgs ++ [ user_message ] }, Cmd.none )

                Err message ->
                    Debug.log ("Error receiving name " ++ Debug.toString message)
                        ( model, Cmd.none )

        OnlineUsers jsonUsers ->
            case Decode.decodeValue usersDecoder jsonUsers of
                Ok usersOnline ->
                    Debug.log ("userssssss" ++ Debug.toString usersOnline)
                        ( { model | usersOnline = Set.fromList usersOnline }, Cmd.none )

                Err message ->
                    Debug.log ("Error receiving list of online users  " ++ Debug.toString message)
                        ( model, Cmd.none )

        NewOnlineUser jsonName ->
            case Decode.decodeValue (stringDecoder "name") jsonName of
                Ok user ->
                    if user /= model.name then
                        if model.friend == "" then
                            ( { model | usersOnline = Set.insert user model.usersOnline, friend = user }, Cmd.none )

                        else
                            ( { model | usersOnline = Set.insert user model.usersOnline }, Cmd.none )

                    else
                        ( model, Cmd.none )

                Err message ->
                    Debug.log ("Error receiving online user name " ++ Debug.toString message)
                        ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        UpdateFriend name ->
            ( { model | friend = name }, Cmd.none )


getName : Url.Url -> String
getName url =
    Maybe.withDefault "" (parse routeParser url)



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ messageReceiver ReceiveMsg
        , receiveUsers OnlineUsers
        , newOnlineUser NewOnlineUser
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "url"
    , body =
        [ div []
            [ form
                [ Events.onSubmit (SendMsg model.msg) ]
                [ div []
                    [ div [] [ text ("Hello " ++ model.name ++ "!\n") ]
                    , text ("Write to " ++ model.friend ++ "!")
                    , viewMsgs model.msgs
                    , viewInput "input" "write msg" model.msg HandleMsg
                    , sendButton model
                    , viewOnlineUsers model.usersOnline
                    ]
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


viewOnlineUsers users =
    ul []
        (List.map
            (\user ->
                li []
                    [ p
                        [ Events.onClick (UpdateFriend user), class "controll", class "button" ]
                        [ text user
                        ]
                    ]
            )
            (Set.toList users)
        )


sendButton : Model -> Html Msg
sendButton model =
    let
        broadcastEvent =
            model.msg
                |> SendMsg
                |> Events.onClick
    in
    button
        [ broadcastEvent
        , type_ "button"
        , Html.Attributes.class "button is-danger"
        ]
        [ text "send" ]
