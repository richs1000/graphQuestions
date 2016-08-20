module Search exposing (..)

import Types exposing (..)
import Graph exposing (..)


breadthFirstSearch : Graph -> NodeId -> NodeId -> Maybe (List NodeId)
breadthFirstSearch graph startNode endNode =
    genericSearch graph startNode endNode


genericSearch : Graph -> NodeId -> NodeId -> Maybe (List NodeId)
genericSearch graph startNode endNode =
    let
        searchHelper openList closedList searchTree =
            case openList of
                -- if the open list is empty then we're done
                [] ->
                    Nothing

                -- else pull the next item off the open list
                firstNode :: restOfList ->
                    --  if the next item is what we're looking for then
                    --  return the path
                    if (firstNode == endNode) then
                        Just (List.reverse (endNode :: (unwindSearchTree searchTree endNode)))
                    else
                        let
                            neighbors =
                                List.filter (edgeExists graph firstNode) graph.nodes
                                    |> List.filter (\n -> not (visited openList closedList n))

                            -- DFS put at start
                            -- BFS put at end
                            openList' =
                                (List.append restOfList neighbors)

                            searchTree' =
                                (( firstNode, neighbors ) :: searchTree)

                            -- start again...
                        in
                            case neighbors of
                                [] ->
                                    (searchHelper openList' (firstNode :: closedList) searchTree')

                                _ ->
                                    (searchHelper openList' (firstNode :: closedList) searchTree')
    in
        searchHelper [ startNode ] [] []


unwindSearchTree : List ( NodeId, List NodeId ) -> NodeId -> List NodeId
unwindSearchTree searchTree lastNode =
    case searchTree of
        [] ->
            []

        ( node, children ) :: rest ->
            if (List.member lastNode children) then
                node :: (unwindSearchTree rest node)
            else
                unwindSearchTree rest lastNode


pathExists : Graph -> NodeId -> NodeId -> Bool
pathExists graph startNode endNode =
    let
        s =
            breadthFirstSearch graph startNode endNode
    in
        case s of
            Nothing ->
                False

            Just _ ->
                True
