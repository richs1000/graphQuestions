module MessageTypes exposing (..)

import Graph exposing (NodeId, EdgeWeight)


type alias SSData =
    { mastery : Bool
    , numerator : Int
    , denominator : Int
    , weighted : Bool
    , directed : Bool
    , implementMastery : Bool
    , debug : Bool
    }


type Msg
    = Reset
    | NewRandomValues (List Int)
    | NewNodes (List NodeId)
    | NewEdgeWeights (List EdgeWeight)
    | NewQuestion Int
    | UserInput String
    | Submit
    | GiveFeedback
    | CheckMastery
    | BreadthFirstSearch
    | ToggleWeighted
    | ToggleDirectional
    | UpdateMastery
    | GetValuesFromSS SSData
