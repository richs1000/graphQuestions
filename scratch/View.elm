module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Pixels =
    Int


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
