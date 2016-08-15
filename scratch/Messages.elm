module Messages exposing (..)

import Graph exposing (..)


type Msg
    = Reset
    | NewNodes (List NodeId)
    | NewEdgeWeights (List EdgeWeight)
    | ToggleWeighted
    | ToggleDirectional
    | Respond String
    | Submit
    | BreadthFirstSearch
