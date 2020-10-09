port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, button, div, form, input, li, p, text, ul)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Set exposing (Set)
import Url



-- MAIN
-- main : Html


type alias InitValues =
    { name : String
    , users : List String
    , users_with_msgs : Maybe (List InitUsers)
    }


type alias InitUsers =
    { friend : String
    , msgs : List String
    }


type alias ReceivedMsg =
    { msg : String
    , sender : String
    }


type alias UserMessageState =
    { msgs : List String
    , viewed : Bool
    , online : Bool
    }


type alias UsersMsgs =
    Dict String UserMessageState


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



-- MODEL


type alias Model =
    { name : String
    , friend : String
    , current_msg : String
    , users : UsersMsgs
    , key : Nav.Key
    , url : Url.Url
    }


initialCommand : String -> Cmd Msg
initialCommand name =
    comeOnline name


initialModel : InitValues -> Url.Url -> Nav.Key -> Model
initialModel initValues url key =
    let
        users =
            List.filter (\name -> name /= initValues.name) initValues.users

        usersMsgsAcc =
            Dict.fromList (List.map (\name -> ( name, UserMessageState [] True True )) users)

        localStorageUsersMsgs =
            Maybe.withDefault [] initValues.users_with_msgs

        createUserMsgsState msgs =
            Maybe.map (\_ -> UserMessageState msgs True True)
    in
    { name = initValues.name
    , friend = Maybe.withDefault "" (List.head users)
    , current_msg = ""
    , users =
        List.foldl
            (\localStorage dictAcc ->
                Dict.update localStorage.friend (createUserMsgsState localStorage.msgs) dictAcc
            )
            usersMsgsAcc
            localStorageUsersMsgs
    , key = key
    , url = url
    }


init : InitValues -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init values url key =
    ( initialModel values url key, initialCommand values.name )



-- UPDATE


type Msg
    = Init
    | SendMsg String
    | ReceiveMsg Encode.Value
    | NewOnlineUser Encode.Value
    | HandleMsg String
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | UpdateFriend String


stringDecoder name =
    Decode.field name Decode.string


usersDecoder =
    Decode.field "users" (Decode.list Decode.string)


msgDecoder =
    Decode.map2 ReceivedMsg
        (Decode.field "msg" Decode.string)
        (Decode.field "sender" Decode.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            ( model, Cmd.none )

        SendMsg message ->
            ( { model | current_msg = "", users = Dict.update model.friend (Maybe.map (\{ msgs, viewed } -> UserMessageState (msgs ++ [ model.name ++ ": " ++ message ]) viewed True)) model.users }, sendMessage (UserMsg model.name model.friend message) )

        HandleMsg message ->
            ( { model | current_msg = message }, Cmd.none )

        ReceiveMsg jsonMsg ->
            case Decode.decodeValue msgDecoder jsonMsg of
                Ok user_message ->
                    let
                        dict =
                            Dict.update
                                user_message.sender
                                (Maybe.map
                                    (\{ msgs } ->
                                        UserMessageState (msgs ++ [ user_message.sender ++ ": " ++ user_message.msg ])
                                            (user_message.sender == model.friend)
                                            True
                                    )
                                )
                                model.users
                    in
                    ( { model | users = dict }, Cmd.none )

                Err message ->
                    Debug.log ("Error receiving msg " ++ Debug.toString message)
                        ( model, Cmd.none )

        NewOnlineUser jsonName ->
            case Decode.decodeValue (stringDecoder "name") jsonName of
                Ok user ->
                    if user /= model.name && not (Dict.member model.friend model.users) then
                        if model.friend == "" then
                            ( { model | friend = user, users = Dict.insert user (UserMessageState [] True True) model.users }, Cmd.none )

                        else
                            ( { model | users = Dict.insert user (UserMessageState [] True True) model.users }, Cmd.none )

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
            let
                dict =
                    Dict.update
                        name
                        (Maybe.map
                            (\{ msgs } ->
                                UserMessageState msgs True True
                            )
                        )
                        model.users
            in
            ( { model | friend = name, users = dict }, Cmd.none )



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ messageReceiver ReceiveMsg
        , newOnlineUser NewOnlineUser
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "url"
    , body =
        [ div []
            [ form
                [ Events.onSubmit (SendMsg model.current_msg) ]
                [ div []
                    [ div [] [ text ("Hello " ++ model.name ++ "!\n") ]
                    , text ("Write to " ++ model.friend ++ "!")
                    , viewMsgs model.users model.friend
                    , viewInput "input" "write msg" model.current_msg HandleMsg
                    , sendButton model
                    , viewOnlineUsers model.users model
                    ]
                ]
            ]
        ]
    }


viewMsgs : UsersMsgs -> String -> Html msg
viewMsgs map friend =
    let
        list =
            Maybe.withDefault (UserMessageState [] True True) (Dict.get friend map)
    in
    ul [ class "messages_list" ] (List.map (\m -> li [] [ text m ]) list.msgs)


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, Events.onInput toMsg ] []


returnClass user model =
    let
        struct =
            Maybe.withDefault (UserMessageState [] True True) (Dict.get user model.users)
    in
    if (user /= model.friend) && not struct.viewed then
        "button is-info"

    else
        "button"


viewOnlineUsers users model =
    let
        onlineUsers =
            Dict.foldl
                (\k v acc ->
                    if v.online then
                        k :: acc

                    else
                        acc
                )
                []
                users
    in
    ul []
        (List.map
            (\user ->
                li []
                    [ p
                        [ Events.onClick (UpdateFriend user), class "controll", class (returnClass user model) ]
                        [ text user
                        ]
                    ]
            )
            onlineUsers
        )


sendButton : Model -> Html Msg
sendButton model =
    let
        broadcastEvent =
            model.current_msg
                |> SendMsg
                |> Events.onClick
    in
    button
        [ broadcastEvent
        , type_ "button"
        , Html.Attributes.class "button is-danger"
        ]
        [ text "send" ]
