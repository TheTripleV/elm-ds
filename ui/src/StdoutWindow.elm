module StdoutWindow exposing (..)

import Browser
import Browser.Dom exposing (getViewportOf, setViewportOf)
import Html exposing (..)
import Html.Attributes exposing (class, id, style)
import InfiniteList
import Json.Decode as D
import Lib.Ipc as Ipc exposing (IpcMsg)
import Lib.Ports exposing (updateFrontend)
import Task


main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


type alias Model =
    { stdout : List String, stdoutList : InfiniteList.Model, enabled : Bool }


type Msg
    = AddStdout String
    | InfiniteListMsg InfiniteList.Model
    | UpdateEnableStatus Bool
    | Nop


init : () -> ( Model, Cmd Msg )
init _ =
    ( { stdout = [ "" ], stdoutList = InfiniteList.init, enabled = False }, Cmd.none )


listConfig : InfiniteList.Config String Msg
listConfig =
    InfiniteList.config
        { itemView = itemView
        , itemHeight = InfiniteList.withConstantHeight 20
        , containerHeight = 500
        }
        |> InfiniteList.withOffset 300


itemView : Int -> Int -> String -> Html Msg
itemView _ _ item =
    div [] [ text item ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddStdout s ->
            ( { model | stdout = List.append model.stdout [ s ] }, getViewportOf "stdoutListView" |> Task.andThen (\info -> setViewportOf "stdoutListView" 0 info.scene.height) |> Task.attempt (\_ -> Nop) )

        UpdateEnableStatus enabled ->
            ( { model | enabled = enabled }, Cmd.none )

        InfiniteListMsg list ->
            ( { model | stdoutList = list }
            , getViewportOf "stdoutListView"
                |> Task.andThen
                    (\info ->
                        setViewportOf "stdoutListView"
                            info.viewport.x
                            (if model.enabled then
                                info.scene.height

                             else
                                info.viewport.y
                            )
                    )
                |> Task.attempt (\_ -> Nop)
            )

        Nop ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        [ style "width" "100%"
        , style "height" "100%"
        , style "overflow-x" "hidden"
        , style "overflow-y" "auto"
        , style "-webkit-overflow-scrolling" "touch"
        , style "color" "#fff"
        , class "form-control"
        , class "bg-dark"
        , id "stdoutListView"
        , InfiniteList.onScroll InfiniteListMsg
        ]
        [ InfiniteList.view listConfig model.stdoutList model.stdout
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    updateFrontend
        (\value ->
            let
                m =
                    D.decodeValue Ipc.decodeMsg value
            in
            case m of
                Ok packet ->
                    case packet of
                        Ipc.NewStdout { message } ->
                            AddStdout message

                        Ipc.UpdateEnableStatus { enabled } ->
                            UpdateEnableStatus enabled

                        _ ->
                            Nop

                Err e ->
                    Nop
        )
