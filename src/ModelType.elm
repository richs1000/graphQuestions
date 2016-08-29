module ModelType exposing (..)

import Graph exposing (Graph, NodeId, EdgeWeight)
import Question exposing (Question)
import HistoryTypes exposing (HistoryList)


-- MODEL


type alias Model =
    { graph : Graph
    , debug : Bool
    , userInput : String
    , history : HistoryList
    , bfs : Maybe (List NodeId)
    , question : Question
    , success : Maybe Bool
    , feedback : String
    , randomValues : List Int
    , mastery : Bool
    , numerator : Int
    , denominator : Int
    , implementMastery : Bool
    }
