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
                    , Random.generate NewEdgeWeights (Random.list (List.length newEdges) (Random.int -1 5))
                    )

            NewEdgeWeights newWeights ->
                let
                    newEdges =
                        (replaceWeights edges newWeights)
                in
                    ( updateGraph model nodes newEdges directed weighted
                    , Random.generate NewQuestion (Random.int 1 8)
                    )

            -- New Question Flow: NewQuestion -> UserInput -> Submit -> Give Feedback -> Check Mastery -> New Graph Flow
            NewQuestion questionIndex ->
                ( newQuestion model questionIndex, Cmd.none )

            UserInput i ->
                ( { model | userInput = i }, Cmd.none )

            Submit ->
                if (String.isEmpty model.userInput) then
                    ( model, Cmd.none )
                else
                    ( checkAnswer model, Cmd.none )

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
