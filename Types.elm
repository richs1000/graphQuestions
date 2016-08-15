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
    }


initModel : Model
initModel =
    { graph = emptyGraph
    , debug = True
    , userInput = ""
    , history = List.repeat historyLength Nothing
    , bfs = Nothing
    , success = Nothing
    , question = emptyQuestion
    , feedback = ""
    , randomValues = []
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


type alias Pixels =
    Int


type alias ViewConstants =
    { nodeSeparation : Pixels
    , nodeRadius : Pixels
    , nodeOffset : Pixels
    , weightOffset : Pixels
    , graphUpperLeft : ( Pixels, Pixels )
    , nodesPerRow : Int
    , nodesPerCol : Int
    , historySquareSize : Int
    , historySquareSeparation : Int
    }


viewConstants : ViewConstants
viewConstants =
    { nodeSeparation = 100
    , nodeRadius = 20
    , nodeOffset = 30
    , weightOffset = 7
    , graphUpperLeft = ( 20, 20 )
    , nodesPerRow = 4
    , nodesPerCol = 4
    , historySquareSize = 25
    , historySquareSeparation = 5
    }



-- UPDATE


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
