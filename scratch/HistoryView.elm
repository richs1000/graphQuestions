module HistoryView exposing (..)

import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Model exposing (..)
import Messages exposing (Msg(..))


historySquareSize : Int
historySquareSize =
    25


historySquareSeparation : Int
historySquareSeparation =
    5


historySection : Model -> Html Msg
historySection model =
    Svg.svg
        [ version "1.1"
        , baseProfile "full"
        , Svg.Attributes.width
            (toString
                (historyLength
                    * (historySquareSize + historySquareSeparation)
                )
            )
        , Svg.Attributes.height "50"
        ]
        (historyList model.history 0)


historySquare : Bool -> Int -> Svg a
historySquare h i =
    let
        base =
            [ Svg.Attributes.width (toString historySquareSize)
            , Svg.Attributes.height (toString historySquareSize)
            , y "10"
            ]

        incorrect =
            List.append base [ fill "red" ]

        correct =
            List.append base [ fill "green" ]

        myX =
            10 + (historySquareSize + historySquareSeparation) * i
    in
        if h then
            rect (List.append [ x (toString myX) ] correct) []
        else
            rect (List.append [ x (toString myX) ] incorrect) []


historyList : HistoryList -> Int -> List (Svg a)
historyList history index =
    case history of
        h :: hs ->
            (historySquare h index) :: (historyList hs (index + 1))

        [] ->
            []
