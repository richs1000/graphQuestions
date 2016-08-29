module Graph exposing (..)


type alias NodeId =
    Int


type alias EdgeWeight =
    Int



-- An edge may be unidirectional (from one node to another), or
-- bi-directional (between two nodes).


type ArrowDirection
    = UniDirectional
    | BiDirectional



-- An edge goes between two nodes. It may have a weight and it may
-- be unidirectional (an arrow at one end), bidirectional (an arrow
-- at both ends) or it may not have a direction (no arrows)


type alias Edge =
    { from : NodeId
    , to : NodeId
    , weight : EdgeWeight
    , direction : ArrowDirection
    }


type alias Graph =
    { nodes : List NodeId
    , edges : List Edge
    , directed : Bool
    , weighted : Bool
    , nodesPerRow : Int
    , nodesPerCol : Int
    }


nodeRow : Graph -> NodeId -> Int
nodeRow graph node =
    node // graph.nodesPerCol


sameRow : Graph -> NodeId -> NodeId -> Bool
sameRow graph n1 n2 =
    (n1 // graph.nodesPerCol) == (n2 // graph.nodesPerCol)


nodeCol : Graph -> NodeId -> Int
nodeCol graph node =
    node `rem` graph.nodesPerCol


sameCol : Graph -> NodeId -> NodeId -> Bool
sameCol graph n1 n2 =
    (n1 `rem` graph.nodesPerCol) == (n1 `rem` graph.nodesPerCol)


closestNeighbor : Graph -> NodeId -> (NodeId -> NodeId -> Bool) -> Int -> Maybe NodeId
closestNeighbor graph fromNode pred offset =
    let
        closestNeighborHelper nodeId =
            if (nodeId < 0) || (nodeId >= graph.nodesPerRow * graph.nodesPerCol) then
                Nothing
            else if (List.member nodeId graph.nodes) && (pred fromNode nodeId) then
                Just nodeId
            else
                closestNeighborHelper (nodeId + offset)
    in
        closestNeighborHelper (fromNode + offset)



-- Given a node, find the closest nodes above, below, to the left and to
-- the right. If any of these doesn't exist, return a Nothing value


findNeighbors : Graph -> NodeId -> List (Maybe NodeId)
findNeighbors graph node =
    [ closestNeighbor graph node (sameRow graph) 1
    , closestNeighbor graph node (sameRow graph) -1
    , closestNeighbor graph node (sameCol graph) graph.nodesPerRow
    , closestNeighbor graph node (sameCol graph) -graph.nodesPerRow
    ]



-- Given a node and a list of nodes it connects to, create edges
-- from the node to each of its neighbors


createEdgesFromNode : NodeId -> List NodeId -> List Edge
createEdgesFromNode fromNode neighbors =
    case neighbors of
        [] ->
            []

        n :: ns ->
            (Edge fromNode n 0 UniDirectional) :: (createEdgesFromNode fromNode ns)



-- Given a list of maybes, return a list with only the values


stripList : List (Maybe a) -> List a
stripList maybes =
    case maybes of
        [] ->
            []

        (Just m) :: ms ->
            m :: (stripList ms)

        Nothing :: ms ->
            stripList ms



-- Given a graph with nodes, create all edges between each node such that:
-- * each edge is either horizontal or vertical
-- * edges don't pass through nodes


createAllEdges : Graph -> Graph
createAllEdges graph =
    let
        createAllEdgesHelper nodes =
            case nodes of
                [] ->
                    []

                n :: ns ->
                    List.append
                        (createEdgesFromNode n
                            (stripList (Debug.log "findNeighbors " (findNeighbors graph n)))
                        )
                        (createAllEdgesHelper ns)

        edges' =
            createAllEdgesHelper graph.nodes
    in
        { graph | edges = edges' }


updateGraph : Graph -> List NodeId -> List Edge -> Bool -> Bool -> Int -> Int -> Graph
updateGraph graph ns es d w npr npc =
    { graph
        | nodes = ns
        , edges = es
        , directed = d
        , weighted = w
        , nodesPerRow = npr
        , nodesPerCol = npc
    }


visited : List NodeId -> List NodeId -> NodeId -> Bool
visited openList closedList node =
    (List.member node openList) || (List.member node closedList)


edgeExists : Graph -> NodeId -> NodeId -> Bool
edgeExists graph n1 n2 =
    let
        -- is there an edge (uni- or bi-directional) from n1 to n2
        n1_to_n2 =
            List.any (\e -> e.from == n1 && e.to == n2) graph.edges

        -- is there a bidirectional edge from n2 to n1
        n2_to_n1_bi =
            List.any (\e -> e.from == n2 && e.to == n1 && e.direction == BiDirectional) graph.edges

        -- the graph is non-directional and there is an edge from n2 to n1
        n2_to_n1_non =
            (not graph.directed) && List.any (\e -> e.from == n2 && e.to == n1) graph.edges
    in
        n1_to_n2 || n2_to_n1_bi || n2_to_n1_non


degree : Graph -> NodeId -> Int
degree graph node =
    graph.edges
        |> List.filter (\e -> e.from == node || e.to == node)
        |> List.length


inDegree : Graph -> NodeId -> Int
inDegree graph node =
    graph.edges
        |> List.filter (\e -> (e.to == node) || (e.from == node && e.direction == BiDirectional))
        |> List.length


outDegree : Graph -> NodeId -> Int
outDegree graph node =
    graph.edges
        |> List.filter (\e -> (e.from == node) || (e.to == node && e.direction == BiDirectional))
        |> List.length


numberOfNodes : Graph -> Int
numberOfNodes graph =
    List.length graph.nodes


numberOfEdges : Graph -> Int
numberOfEdges graph =
    List.length graph.edges


firstNode : Graph -> NodeId
firstNode graph =
    case graph.nodes of
        [] ->
            0

        n :: ns ->
            n


lastNode : Graph -> NodeId
lastNode graph =
    let
        nodes' =
            List.reverse graph.nodes
    in
        case nodes' of
            [] ->
                0

            n :: ns ->
                n



-- This function replaces the weights on each of the edges in a graph. Then it
-- removes all the edges with weights less than or equal to zero. Then it
-- merges each pair of matching unidirectional edges into a single
-- bi-directional edge


replaceWeights : Graph -> List EdgeWeight -> Graph
replaceWeights graph newWeights =
    let
        edges' =
            newWeights
                -- create a new list of edges with new weights
                |>
                    List.map2 (\e w -> { from = e.from, to = e.to, direction = e.direction, weight = w }) graph.edges
                -- remove all edges with weight <= 0
                |>
                    List.filter (\e -> e.weight > 0)

        graph' =
            { graph | edges = edges' }
    in
        graph'
            -- merge matched edges into single bi-directional edges
            |>
                mergeDuplicateEdges
            -- remove a vertical edge if it crosses a horizontal edge
            |>
                removeOverlappingEdges



-- Find all edges (e, e') where e.from = e'.to and e.to = e'.from and merge
-- them into single bi-directional edges


mergeDuplicateEdges : Graph -> Graph
mergeDuplicateEdges graph =
    let
        helperFunc edges =
            case edges of
                [] ->
                    []

                e :: es ->
                    let
                        ( rev, notRev ) =
                            List.partition (\ee -> e.to == ee.from && e.from == ee.to) es
                    in
                        case rev of
                            [] ->
                                e :: helperFunc notRev

                            r :: rs ->
                                { e | direction = BiDirectional } :: helperFunc notRev

        edges' =
            helperFunc graph.edges
    in
        { graph | edges = edges' }



-- Remove all edges in the graph that overlap when drawn. This is tightly
-- connected to the view of the graph, which is unfortunate.


removeOverlappingEdges : Graph -> Graph
removeOverlappingEdges graph =
    let
        helperFunc edges =
            case edges of
                [] ->
                    []

                e :: es ->
                    let
                        ( overlap, notOverlap ) =
                            List.partition (\ee -> (edgesOverlap graph e ee) || (edgesOverlap graph ee e)) es
                    in
                        e :: helperFunc notOverlap

        edges' =
            helperFunc graph.edges
    in
        { graph | edges = edges' }


edgesOverlap : Graph -> Edge -> Edge -> Bool
edgesOverlap g e1 e2 =
    let
        isHorizontal e =
            sameRow g e.from e.to

        isVertical e =
            sameCol g e.from e.to

        nodeRowG n =
            nodeRow g n

        nodeColG n =
            nodeCol g n

        between f e1 e2 =
            ((f e2.from)
                < (f e1.from)
                && (f e1.from)
                < (f e2.to)
                || (f e2.to)
                < (f e1.from)
                && (f e1.from)
                < (f e2.from)
            )
    in
        -- e1 is horizontal - in same row
        (isHorizontal e1)
            && -- e2 is vertical - in same column
               (isVertical e2)
            && -- row of e1 is between rows of e2
               (between nodeRowG e1 e2)
            && -- col of e2 is between columns of e1
               (between nodeColG e1 e2)



-- Choose the index of a random node from within the graph. If there are no
-- nodes, then return an index of zero


randomNode : Graph -> List Int -> List NodeId -> NodeId
randomNode graph randomValues alreadyChosen =
    let
        validNodes =
            randomValues
                |> List.filter (\n -> List.member n graph.nodes)
                |> List.filter (\n -> not (List.member n alreadyChosen))

        rNode =
            List.head validNodes
    in
        case rNode of
            Nothing ->
                0

            Just n ->
                n



-- Choose a random edge from within the graph. If there are no edges then
-- return an "empty" edge


randomEdge : Graph -> List Int -> Edge
randomEdge graph randomValues =
    let
        edges =
            graph.edges

        index =
            randomValues
                |> List.filter (\n -> n < List.length edges)
                |> List.head

        i =
            Maybe.withDefault ((List.length edges) - 1) index

        edge =
            List.head (List.drop i edges)
    in
        case edge of
            Nothing ->
                emptyEdge

            Just e ->
                e


emptyEdge : Edge
emptyEdge =
    { from = 0
    , to = 0
    , weight = 0
    , direction = UniDirectional
    }


emptyGraph : Graph
emptyGraph =
    { nodes = []
    , edges = []
    , directed = True
    , weighted = True
    , nodesPerRow = 4
    , nodesPerCol = 4
    }
