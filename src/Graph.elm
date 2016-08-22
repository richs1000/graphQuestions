module Graph exposing (..)

import Types exposing (..)
import GraphTypes exposing (..)


-- Overlap with VIEW


nodesPerRow : Int
nodesPerRow =
    4


nodesPerCol : Int
nodesPerCol =
    4


nodeRow : NodeId -> Int
nodeRow node =
    node // nodesPerCol


sameRow : NodeId -> NodeId -> Bool
sameRow n1 n2 =
    (n1 // nodesPerCol) == (n2 // nodesPerCol)


nodeCol : NodeId -> Int
nodeCol node =
    node `rem` nodesPerCol


sameCol : NodeId -> NodeId -> Bool
sameCol n1 n2 =
    (n1 `rem` nodesPerCol) == (n1 `rem` nodesPerCol)


closestNeighbor : List NodeId -> NodeId -> (NodeId -> NodeId -> Bool) -> Int -> Maybe NodeId
closestNeighbor allNodes fromNode pred offset =
    let
        closestNeighborHelper nodeId =
            if (nodeId < 0) || (nodeId >= nodesPerRow * nodesPerCol) then
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
    , closestNeighbor nodes node sameCol nodesPerRow
    , closestNeighbor nodes node sameCol -nodesPerRow
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


updateGraph : Model -> List NodeId -> List Edge -> Bool -> Bool -> Model
updateGraph model ns es d w =
    { model | graph = { nodes = ns, edges = es, directed = d, weighted = w } }


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


numberOfNodes : Model -> Int
numberOfNodes model =
    let
        { nodes, edges, directed, weighted } =
            model.graph
    in
        List.length nodes


numberOfEdges : Model -> Int
numberOfEdges model =
    let
        { nodes, edges, directed, weighted } =
            model.graph
    in
        List.length edges


firstNode : Model -> NodeId
firstNode model =
    let
        { nodes, edges, directed, weighted } =
            model.graph
    in
        case nodes of
            [] ->
                0

            n :: ns ->
                n


lastNode : Model -> NodeId
lastNode model =
    let
        { nodes, edges, directed, weighted } =
            model.graph

        nodes' =
            List.reverse nodes
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


mergeDuplicates : List Edge -> List Edge
mergeDuplicates edges =
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
                        e :: mergeDuplicates notRev

                    r :: rs ->
                        { e | direction = BiDirectional } :: mergeDuplicates notRev


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


randomNode : Model -> List NodeId -> NodeId
randomNode model alreadyChosen =
    let
        graph =
            model.graph

        validNodes =
            model.randomValues
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


randomEdge : Model -> Edge
randomEdge model =
    let
        graph =
            model.graph

        edges =
            graph.edges

        index =
            model.randomValues
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
    }
