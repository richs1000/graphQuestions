module Questions exposing (..)


type alias ResponseAndFeedback =
    ( String, String )


type alias QuestionTemplate =
    { question : String
    , data : List ( String, String )
    , answer : ResponseAndFeedback
    , distractors : List ResponseAndFeedback
    }


numberOfNodes : Model -> String
numberOfNodes model =
    let
        { nodes, edges, directional, weighted } =
            model.graph
    in
        List.length nodes


numberOfEdges : Model -> String
numberOfEdges model =
    let
        { nodes, edges, directional, weighted } =
            model.graph
    in
        List.length edges


isThereAnEdge : QuestionTemplate
isThereAnEdge =
    { question = "Is there an edge from node _x_ to node _y_?"
    , data =
        [ ( "_x_", randomNumber )
        , ( "_y_", randomNumber )
        ]
    , answer =
        ( edgeExists [ "_x_" "_y_" ]
        , "Correct"
        )
    , distractors =
        [ (not edgeExists [ "_x_" "_y_" ])
        , "Incorrect. An edge between two nodes is indicated by a line connecting two circles"
        ]
    }


howManyNodes : QuestionTemplate
howManyNodes =
    { question = "How many nodes does this graph have"
    , data = []
    , answer =
        ( numberOfNodes
        , "Correct"
        )
    , distractors =
        [ ( numberOfEdges
          , "That is the number of edges. Nodes are the labeled circles in the picture above."
          )
        , ( randomNumber
          , "Incorrect. Nodes are the labeled circles in the picture above."
          )
        ]
    }


type alias Question =
    { question : String
    , distractors : List ResponseAndFeedback
    , answer : ResponseAndFeedback
    }


questionByIndex : Model -> Int -> Question
questionByIndex model index =
    if index == 1 then
        { question = "How many nodes are in the graph above?"
        , distractors =
            [ ( toString (numberOfEdges model)
              , "That is the number of edges. Nodes are the labeled circles in the picture above."
              )
            ]
        , answer =
            ( toString (numberOfNodes model)
            , "Correct."
            )
        }
    else
        { question = "How many edges are in the graph above?"
        , distractors =
            [ ( toString (numberOfNodes model)
              , "That is the number of nodes. Edges are the lines connecting circles in the picture above. A bi-directional edge (i.e., an edge with two arrows) still counts as a single edge."
              )
            ]
        , answer =
            ( toString (numberOfEdges model)
            , "Correct."
            )
        }


newQuestion : Model -> Int -> Model
newQuestion model index =
    let
        { nodes, edges, directional, weighted } =
            model.graph

        newQuestion =
            questionByIndex model index
    in
        { model | question = newQuestion, success = Nothing }


checkAnswer : Model -> Model
checkAnswer model =
    let
        newHistory =
            List.take (historyLength - 1) model.history
    in
        if model.answer == model.response then
            { model | response = "", success = Just True, history = (Just True) :: newHistory }
        else
            { model | response = "", success = Just False, history = (Just False) :: newHistory }



-- , questionList = []
-- , question = ""
-- , answer = ""
-- , success = Nothing
-- , feedback = ""
