-- This module exists because the view of the graph and the model of the graph
-- intersect and I needed a place to isolate that. The "problem" is that I don't
-- want to create edges that overlap. In order to do that, I need access to the
-- model (to add/filter edges) and I need access to the view (how the graph is
-- displayed). I'm sure there is a more elegant solution, but this is where I
-- am right now.


module GraphCreateEdges exposing (..)

import Graph exposing (..)
import DrawGraph exposing (..)


closestNeighbor : List NodeId -> NodeId -> (NodeId -> NodeId -> Bool) -> Int -> Maybe NodeId
closestNeighbor allNodes fromNode pred offset =
    let
        closestNeighborHelper nodeId =
            if (nodeId < 0) || (nodeId >= viewConstants.nodesPerRow * viewConstants.nodesPerCol) then
                Nothing
            else if (List.member nodeId allNodes) && (pred fromNode nodeId) then
                Just nodeId
            else
                closestNeighborHelper (nodeId + offset)
    in
        closestNeighborHelper (fromNode + offset)



-- Given a node, find the closest nodes above, below, to the left and to
-- the right. If any of these doesn't exist, return a Nothing value


findNeighbors : List NodeId -> NodeId -> List (Maybe NodeId)
findNeighbors nodes node =
    [ closestNeighbor nodes node sameRow 1
    , closestNeighbor nodes node sameRow -1
    , closestNeighbor nodes node sameCol viewConstants.nodesPerRow
    , closestNeighbor nodes node sameCol -viewConstants.nodesPerRow
    ]



-- Given a list of nodes, create all edges between each node such that:
-- * each edge is either horizontal or vertical
-- * edges don't pass through nodes


createAllEdges : List NodeId -> List Edge
createAllEdges nodes =
    let
        createAllEdgesHelper allNodes nodes =
            case nodes of
                [] ->
                    []

                n :: ns ->
                    List.append
                        (createEdgesFromNode n
                            (stripList (findNeighbors allNodes n))
                        )
                        (createAllEdgesHelper allNodes ns)
    in
        createAllEdgesHelper nodes nodes


edgesOverlap : Edge -> Edge -> Bool
edgesOverlap e1 e2 =
    -- e1 is horizontal - in same row
    (sameRow e1.from e1.to)
        && -- e2 is vertical - in same column
           (sameCol e2.from e2.to)
        && -- row of e1 is between rows of e2
           ((nodeRow e2.from)
                < (nodeRow e1.from)
                && (nodeRow e1.from)
                < (nodeRow e2.to)
                || (nodeRow e2.to)
                < (nodeRow e1.from)
                && (nodeRow e1.from)
                < (nodeRow e2.from)
           )
        && -- col of e2 is between columns of e1
           ((nodeCol e1.from)
                < (nodeCol e2.from)
                && (nodeCol e2.from)
                < (nodeCol e1.to)
                || (nodeCol e1.to)
                < (nodeCol e2.from)
                && (nodeCol e2.from)
                < (nodeCol e1.from)
           )


removeOverlappingEdges : List Edge -> List Edge
removeOverlappingEdges edges =
    case edges of
        [] ->
            []

        e :: es ->
            let
                ( overlap, notOverlap ) =
                    List.partition (\ee -> (edgesOverlap e ee) || (edgesOverlap ee e)) es
            in
                e :: removeOverlappingEdges notOverlap
