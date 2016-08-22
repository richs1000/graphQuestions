module GraphTypes exposing (..)


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
    }
