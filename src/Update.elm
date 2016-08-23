module Update exposing (..)

import Random exposing (..)
import Set exposing (..)
import String exposing (..)
import Types exposing (..)
import Graph exposing (..)
import Question exposing (..)
import Search exposing (..)
import Ports exposing (..)
import Model exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { nodes, edges, directed, weighted, nodesPerRow, nodesPerCol } =
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
                    graph =
                        model.graph

                    newNodes' =
                        Set.toList (Set.fromList newNodes)

                    graph' =
                        createAllEdges { graph | nodes = newNodes' }
                in
                    ( { model | graph = graph' }
                    , Random.generate NewEdgeWeights (Random.list (List.length graph'.edges) (Random.int -1 5))
                    )

            NewEdgeWeights newWeights ->
                let
                    graph' =
                        replaceWeights model.graph newWeights
                in
                    ( { model | graph = graph' }
                    , Random.generate NewQuestion (Random.int 1 8)
                    )

            -- New Question Flow: NewQuestion -> UserInput -> Submit -> Give Feedback -> Check Mastery -> New Graph Flow
            NewQuestion questionIndex ->
                let
                    question' =
                        newQuestion model.graph model.randomValues questionIndex
                in
                    ( { model | question = question', success = Nothing, userInput = "" }, Cmd.none )

            UserInput i ->
                ( { model | userInput = i }, Cmd.none )

            Submit ->
                if (String.isEmpty model.userInput) then
                    ( model, Cmd.none )
                else
                    -- ( checkAnswer model, Cmd.none )
                    let
                        newHistory =
                            List.take (model.denominator - 1) model.history

                        { question, distractors, answer } =
                            model.question
                    in
                        if (fst answer) == model.userInput then
                            ( { model | success = Just True, history = (Just True) :: newHistory, feedback = (snd answer) }, Cmd.none )
                        else
                            ( { model | success = Just False, history = (Just False) :: newHistory, feedback = (findFeedback (fst answer) model.userInput distractors) }, Cmd.none )

            GiveFeedback ->
                update CheckMastery model

            CheckMastery ->
                if masteryAchieved model then
                    update UpdateMastery { model | mastery = True }
                else
                    ( { model | mastery = False }
                    , Random.generate NewRandomValues (Random.list 15 (Random.int 1 15))
                    )

            -- Debug actions
            ToggleWeighted ->
                let
                    graph' =
                        updateGraph model.graph nodes edges directed (not weighted) nodesPerRow nodesPerCol
                in
                    ( { model | graph = graph' }, Cmd.none )

            ToggleDirectional ->
                let
                    graph' =
                        updateGraph model.graph nodes edges (not directed) weighted nodesPerRow nodesPerCol
                in
                    ( { model | graph = graph' }, Cmd.none )

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
                ( model, updateMastery model.mastery )

            GetValuesFromSS ssd ->
                let
                    graph =
                        model.graph

                    graph' =
                        -- Debug.log "got values from smart sparrow: "
                        { graph | weighted = ssd.weighted, directed = ssd.directed }
                in
                    ( { model
                        | mastery = ssd.mastery
                        , numerator = ssd.numerator
                        , denominator = ssd.denominator
                        , implementMastery = ssd.implementMastery
                        , graph = graph'
                        , debug = ssd.debug
                      }
                    , Random.generate NewRandomValues (Random.list 15 (Random.int 1 15))
                    )
