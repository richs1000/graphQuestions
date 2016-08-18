module Types exposing (..)

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
    , weighted : Bool
    , directional : Bool
    }



-- HISTORY


type alias HistoryList =
    List (Maybe Bool)


historyLength : Int
historyLength =
    10



-- QUESTION


type QuestionFormat
    = FillInTheBlank
    | MultipleChoice


type alias Question =
    { question : String
    , distractors : List ResponseAndFeedback
    , answer : ResponseAndFeedback
    , format : QuestionFormat
    }


type alias ResponseAndFeedback =
    ( String, String )


emptyQuestion : Question
emptyQuestion =
    { question = ""
    , distractors = []
    , answer = ( "", "" )
    , format = FillInTheBlank
    }



-- GRAPH


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


emptyEdge : Edge
emptyEdge =
    { from = 0
    , to = 0
    , weight = 0
    , direction = UniDirectional
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



-- VIEW
-- UPDATE


type alias SSData =
    { num : Int
    , den : Int
    , weighted : Bool
    , directed : Bool
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
    | BreadthFirstSearch
    | ToggleWeighted
    | ToggleDirectional
    | UpdateMastery
    | GetValuesFromSS SSData
