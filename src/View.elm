module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import GraphView exposing (..)
import HistoryView exposing (..)
import DebugView exposing (..)
import QuestionView exposing (..)
import MessageTypes exposing (..)


scoreboardStyle : Html.Attribute msg
scoreboardStyle =
    Html.Attributes.style
        [ ( "border-top", "1px solid #000" )
        , ( "border-bottom", "1px solid #000" )
        , ( "background", "#ffffcc" )
        , ( "height", "40px" )
        , ( "margin-left", "6px" )
        , ( "margin-right", "6px" )
        ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [ scoreboardStyle ] [ Html.text "Test Your Understanding" ]
        , imageOfGraph model.graph
        , questionForm model
        , historySection model
        , debugSection model
        ]
