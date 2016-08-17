module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


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


questionStyle : Html.Attribute msg
questionStyle =
    Html.Attributes.style
        [ ( "width", "100%" )
        , ( "height", "40px" )
        , ( "padding", "10px" )
        , ( "font-size", "2em" )
        , ( "margin", "4px" )
          -- , ( "line-height", "3" )
        ]


buttonStyle : Html.Attribute msg
buttonStyle =
    Html.Attributes.style
        [ ( "text-align", "center" )
        , ( "font-size", "16px" )
        , ( "padding", "15px 32px" )
        , ( "margin", "2px" )
          -- , ( "display", "inline-block" )
        ]


radioStyle : Html.Attribute msg
radioStyle =
    Html.Attributes.style
        [ ( "width", "40px" )
        , ( "height", "40px" )
        , ( "border-radius", "50%" )
        ]


inputStyle : Html.Attribute msg
inputStyle =
    Html.Attributes.style
        [ ( "width", "100%" )
        , ( "height", "40px" )
        , ( "padding", "10px" )
        , ( "font-size", "2em" )
        , ( "margin", "8px" )
        ]


type alias Pixels =
    Int


type alias ViewConstants =
    { nodeSeparation : Pixels
    , nodeRadius : Pixels
    , nodeOffset : Pixels
    , weightOffset : Pixels
    , graphUpperLeft : ( Pixels, Pixels )
    , nodesPerRow : Int
    , nodesPerCol : Int
    , historySquareSize : Int
    , historySquareSeparation : Int
    }


viewConstants : ViewConstants
viewConstants =
    { nodeSeparation = 100
    , nodeRadius = 20
    , nodeOffset = 30
    , weightOffset = 7
    , graphUpperLeft = ( 40, 20 )
    , nodesPerRow = 4
    , nodesPerCol = 4
    , historySquareSize = 25
    , historySquareSeparation = 5
    }
