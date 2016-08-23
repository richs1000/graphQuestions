module Types exposing (..)

import Graph exposing (Graph, NodeId, EdgeWeight)
import QuestionTypes exposing (Question)
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



-- HISTORY
-- QUESTION
-- GRAPH
-- VIEW


type alias Pixels =
    Int



-- UPDATE


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
