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
    , directional : Bool
    , weighted : Bool
    }


emptyGraph : Graph
emptyGraph =
    { nodes = []
    , edges = []
    , directional = True
    , weighted = True
    }


canReach : Graph -> NodeId -> NodeId -> Bool
canReach graph n1 n2 =
    let
        -- is there an edge (uni- or bi-directional) from n1 to n2
        n1_to_n2 =
            List.any (\e -> e.from == n1 && e.to == n2) graph.edges

        -- is there a bidirectional edge from n2 to n1
        n2_to_n1_bi =
            List.any (\e -> e.from == n2 && e.to == n1 && e.direction == BiDirectional) graph.edges

        -- the graph is non-directional and there is an edge from n2 to n1
        n2_to_n1_non =
            (not graph.directional) && List.any (\e -> e.from == n2 && e.to == n1) graph.edges
    in
        n1_to_n2 || n2_to_n1_bi || n2_to_n1_non



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
