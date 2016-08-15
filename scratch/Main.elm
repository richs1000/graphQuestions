module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import HistoryView exposing (..)
import Messages exposing (Msg(..))
import Model exposing (..)
import View exposing (..)
import QuestionView exposing (..)
import DrawGraph exposing (..)
import Update exposing (..)
import Graph exposing (..)


-- MAIN


main : Program Never
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


initModel : Model
initModel =
    { graph = emptyGraph
    , debug = True
    , response = ""
    , history = emptyHistory
    , bfs = Nothing
    , success = Nothing
    }


init : ( Model, Cmd Msg )
init =
    update Reset initModel



-- VIEW


view : Model -> Html Msg
view model =
    let
        resetBtn =
            button [ onClick Reset ] [ Html.text "Reset" ]

        buttons =
            if model.debug then
                div []
                    [ resetBtn
                    , button [ onClick ToggleWeighted ] [ Html.text "Toggle Weighted" ]
                    , button [ onClick ToggleDirectional ] [ Html.text "Toggle Directional" ]
                    , button [ onClick BreadthFirstSearch ] [ Html.text "BFS" ]
                    ]
            else
                div [] [ resetBtn ]
    in
        div []
            [ h1 [ scoreboardStyle ] [ Html.text "Mastery Quiz" ]
            , imageOfGraph model
              -- , questionForm model
              -- , historySection model
            , buttons
            , p [] [ Html.text (toString model) ]
            ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
