module GraphQuestions exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Random exposing (..)
import Set exposing (..)
import String exposing (..)
import Debug
import Types exposing (..)
import View exposing (..)
import QuestionView exposing (..)
import HistoryView exposing (..)
import GraphView exposing (..)
import Graph exposing (..)
import Search exposing (..)
import Question exposing (..)
import Ports exposing (..)


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
    , mastery = False
    , numerator = 0
    , denominator = 0
    }


init : ( Model, Cmd Msg )
init =
    update Reset initModel



-- VIEW


view : Model -> Html Msg
view model =
    let
        resetBtn =
            button [ onClick Reset, buttonStyle ] [ Html.text "Reset" ]

        buttons =
            if model.debug then
                div []
                    [ resetBtn
                    , button [ onClick ToggleWeighted, buttonStyle ] [ Html.text "Toggle Weighted" ]
                    , button [ onClick ToggleDirectional, buttonStyle ] [ Html.text "Toggle Directional" ]
                    , button [ onClick BreadthFirstSearch, buttonStyle ] [ Html.text "BFS" ]
                    , button [ onClick UpdateMastery, buttonStyle ] [ Html.text "Mastery" ]
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



-- PORTS
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    ssData GetValuesFromSS



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { nodes, edges, directed, weighted } =
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
                    ( updateGraph model newNodes' newEdges directed weighted
                    , Random.generate NewEdgeWeights (Random.list (List.length newEdges) (Random.int -2 5))
                    )

            NewEdgeWeights newWeights ->
                let
                    newEdges =
                        (replaceWeights edges newWeights)
                in
                    ( updateGraph model nodes newEdges directed weighted
                    , Random.generate NewQuestion (Random.int 1 8)
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
                ( updateGraph model nodes edges directed (not weighted), Cmd.none )

            ToggleDirectional ->
                ( updateGraph model nodes edges (not directed) weighted, Cmd.none )

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

            UpdateMastery ->
                ( { model | mastery = True }, updateMastery True )

            GetValuesFromSS ssd ->
                let
                    graph =
                        model.graph

                    graph' =
                        Debug.log "got values from smart sparrow: "
                            { graph | weighted = ssd.weighted, directed = ssd.directed }
                in
                    ( { model
                        | mastery = ssd.mastery
                        , numerator = ssd.numerator
                        , denominator = ssd.denominator
                        , graph = graph'
                      }
                    , Random.generate NewRandomValues (Random.list 15 (Random.int 1 15))
                    )
