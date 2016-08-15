module Model exposing (..)

import Graph exposing (..)


type alias Model =
    { graph : Graph
    , debug : Bool
    , response : String
    , history : HistoryList
    , bfs : Maybe (List NodeId)
    , success : Maybe Bool
    }



-- History List Model


type alias HistoryList =
    List Bool


historyLength : Int
historyLength =
    10


emptyHistory : HistoryList
emptyHistory =
    List.repeat historyLength False



-- Graph Model


updateGraph : Model -> List NodeId -> List Edge -> Bool -> Bool -> Model
updateGraph model ns es d w =
    { model | graph = { nodes = ns, edges = es, directional = d, weighted = w } }
