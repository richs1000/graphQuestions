module Search exposing (..)

import Graph exposing (..)


type alias SearchTree =
    List ( NodeId, List NodeId )


unwindSearchTree : SearchTree -> NodeId -> List NodeId
unwindSearchTree searchTree lastNode =
    case searchTree of
        [] ->
            []

        ( node, children ) :: rest ->
            if (List.member lastNode (Debug.log "kids" children)) then
                node :: (unwindSearchTree rest node)
            else
                unwindSearchTree rest lastNode


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
                                List.filter (canReach graph firstNode) graph.nodes
                                    |> List.filter (\n -> not (visited openList closedList n))

                            -- DFS put at start
                            -- BFS put at end
                            openList' =
                                (List.append restOfList neighbors)

                            searchTree' =
                                Debug.log "search tree: " (( firstNode, neighbors ) :: searchTree)

                            -- start again...
                        in
                            case neighbors of
                                [] ->
                                    (searchHelper openList' (firstNode :: closedList) searchTree')

                                _ ->
                                    (searchHelper openList' (firstNode :: closedList) searchTree')
    in
        searchHelper [ startNode ] [] []


visited : List NodeId -> List NodeId -> NodeId -> Bool
visited openList closedList node =
    (List.member node openList) || (List.member node closedList)
