module DebugView exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import MessageTypes exposing (Msg(..))


buttonStyle : Html.Attribute msg
buttonStyle =
    Html.Attributes.style
        [ ( "text-align", "center" )
        , ( "font-size", "16px" )
        , ( "padding", "15px 32px" )
        , ( "margin", "2px" )
        ]


debugSection : Model -> Html Msg
debugSection model =
    if model.debug then
        div []
            [ button [ onClick Reset, buttonStyle ] [ Html.text "Reset" ]
            , button [ onClick ToggleWeighted, buttonStyle ] [ Html.text "Toggle Weighted" ]
            , button [ onClick ToggleDirectional, buttonStyle ] [ Html.text "Toggle Directional" ]
            , button [ onClick BreadthFirstSearch, buttonStyle ] [ Html.text "BFS" ]
            , button [ onClick UpdateMastery, buttonStyle ] [ Html.text "Mastery" ]
            , p [] [ Html.text (toString model) ]
            ]
    else
        div [] []
