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
    , graphUpperLeft = ( 20, 20 )
    , nodesPerRow = 4
    , nodesPerCol = 4
    , historySquareSize = 25
    , historySquareSeparation = 5
    }
