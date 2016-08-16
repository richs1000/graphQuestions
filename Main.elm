module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Random exposing (..)
import Set exposing (..)
import String exposing (..)
import Types exposing (..)
import View exposing (..)
import QuestionView exposing (..)
import HistoryView exposing (..)
import GraphView exposing (..)
import Graph exposing (..)
import Search exposing (..)
import Question exposing (..)


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
    , userInput = ""
    , history = List.repeat historyLength Nothing
    , bfs = Nothing
    , success = Nothing
    , question = emptyQuestion
    , feedback = ""
    , randomValues = []
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
            , questionForm model
            , historySection model
            , buttons
            , p [] [ Html.text (toString model) ]
            ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { nodes, edges, directional, weighted } =
            model.graph
    in
        case msg of
            -- Startup flow: Reset -> New Question Flow
            Reset ->
                ( initModel, Random.generate NewRandomValues (Random.list 15 (Random.int 1 15)) )

            -- New Graph Flow: NewRandomValues -> NewNodes -> NewEdgeWeights -> New Question Flow
            NewRandomValues newValues ->
                ( { model | randomValues = newValues }, Random.generate NewNodes (Random.list 15 (Random.int 1 15)) )

            NewNodes newNodes ->
                let
                    newNodes' =
                        Set.toList (Set.fromList newNodes)

                    newEdges =
                        (createAllEdges newNodes')
                in
                    ( updateGraph model newNodes' newEdges directional weighted
                    , Random.generate NewEdgeWeights (Random.list (List.length newEdges) (Random.int -2 5))
                    )

            NewEdgeWeights newWeights ->
                let
                    newEdges =
                        (replaceWeights edges newWeights)
                in
                    ( updateGraph model nodes newEdges directional weighted
                    , Random.generate NewQuestion (Random.int 1 7)
                    )

            -- New Question Flow: NewQuestion -> UserInput -> Submit -> GiveFeedback -> New Graph Flow
            NewQuestion questionIndex ->
                ( newQuestion model questionIndex, Cmd.none )

            UserInput i ->
                ( { model | userInput = i }, Cmd.none )

            Submit ->
                if (String.isEmpty model.userInput) then
                    ( model, Cmd.none )
                else
                    ( checkAnswer model
                    , Cmd.none
                    )

            GiveFeedback ->
                ( model
                , Random.generate NewRandomValues (Random.list 15 (Random.int 1 15))
                )

            -- Debug actions
            ToggleWeighted ->
                ( updateGraph model nodes edges directional (not weighted), Cmd.none )

            ToggleDirectional ->
                ( updateGraph model nodes edges (not directional) weighted, Cmd.none )

            BreadthFirstSearch ->
                let
                    firstNode =
                        (List.head nodes)

                    lastNode =
                        (List.head (List.reverse nodes))
                in
                    case firstNode of
                        Nothing ->
                            ( model, Cmd.none )

                        Just start ->
                            case lastNode of
                                Nothing ->
                                    ( model, Cmd.none )

                                Just finish ->
                                    ( { model | bfs = (breadthFirstSearch model.graph start finish) }, Cmd.none )
