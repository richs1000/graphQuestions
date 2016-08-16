module HistoryView exposing (..)

import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import View exposing (..)
import Types exposing (..)


historySection : Model -> Html Msg
historySection model =
    Svg.svg
        [ version "1.1"
        , baseProfile "full"
        , Svg.Attributes.width
            (toString
                (historyLength
                    * (viewConstants.historySquareSize + viewConstants.historySquareSeparation)
                )
            )
        , Svg.Attributes.height "50"
        ]
        (historyList model.history 0)


historySquare : Maybe Bool -> Int -> Svg a
historySquare h i =
    let
        base =
            [ Svg.Attributes.width (toString viewConstants.historySquareSize)
            , Svg.Attributes.height (toString viewConstants.historySquareSize)
            , y "10"
            ]

        incorrect =
            List.append base [ fill "red" ]

        correct =
            List.append base [ fill "green" ]

        nothing =
            List.append base [ fill "white" ]

        myX =
            10 + (viewConstants.historySquareSize + viewConstants.historySquareSeparation) * i
    in
        case h of
            Just True ->
                rect (List.append [ x (toString myX) ] correct) []

            Just False ->
                rect (List.append [ x (toString myX) ] incorrect) []

            Nothing ->
                rect (List.append [ x (toString myX) ] nothing) []


historyList : HistoryList -> Int -> List (Svg a)
historyList history index =
    case history of
        h :: hs ->
            (historySquare h index) :: (historyList hs (index + 1))

        [] ->
            []
