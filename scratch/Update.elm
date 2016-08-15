module Update exposing (..)

import Random
import Set
import String
import Messages exposing (..)
import Model exposing (..)
import Graph exposing (..)
import GraphCreateEdges exposing (..)
import Search exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { nodes, edges, directional, weighted } =
            model.graph
    in
        case msg of
            Reset ->
                ( { model | graph = emptyGraph, response = "" }, Random.generate NewNodes (Random.list 15 (Random.int 1 15)) )

            NewNodes newNodes ->
                let
                    newNodes' =
                        Set.toList (Set.fromList newNodes)

                    newEdges =
                        (createAllEdges newNodes')
                in
                    ( updateGraph model newNodes' newEdges directional weighted, Random.generate NewEdgeWeights (Random.list (List.length newEdges) (Random.int -1 5)) )

            NewEdgeWeights newWeights ->
                let
                    newEdges =
                        (replaceWeights edges newWeights)
                in
                    ( updateGraph model nodes newEdges directional weighted, Cmd.none )

            ToggleWeighted ->
                ( updateGraph model nodes edges directional (not weighted), Cmd.none )

            ToggleDirectional ->
                ( updateGraph model nodes edges (not directional) weighted, Cmd.none )

            Respond r ->
                ( { model | response = r }, Cmd.none )

            Submit ->
                if (String.isEmpty model.response) then
                    ( model, Cmd.none )
                else
                    ( checkAnswer model, Cmd.none )

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


checkAnswer : Model -> Model
checkAnswer model =
    let
        { nodes, edges, directional, weighted } =
            model.graph

        answer =
            (List.length nodes)
    in
        if (toString answer) == model.response then
            { model | success = Just True }
        else
            { model | success = Just False }



-- This function replaces the weights on each of the edges in a graph. Then it
-- removes all the edges with weights less than or equal to zero. Then it
-- merges each pair of matching unidirectional edges into a single
-- bi-directional edge


replaceWeights : List Edge -> List EdgeWeight -> List Edge
replaceWeights edges newWeights =
    newWeights
        -- create a new list of edges with new weights
        |>
            List.map2 (\e w -> { from = e.from, to = e.to, weight = w, direction = e.direction }) edges
        -- remove all edges with weight <= 0
        |>
            List.filter (\e -> e.weight > 0)
        -- merge matched edges into single bi-directional edges
        |>
            mergeDuplicates
        -- remove a vertical edge if it crosses a horizontal edge
        |>
            removeOverlappingEdges
