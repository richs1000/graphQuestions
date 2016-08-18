module Question exposing (..)

import Types exposing (..)
import Graph exposing (..)
import Search exposing (..)


questionByIndex : Model -> Int -> Question
questionByIndex model index =
    let
        { nodes, edges, directed, weighted } =
            model.graph
    in
        if index == 1 then
            { question = "How many nodes are in the graph above?"
            , distractors =
                [ ( toString (numberOfEdges model)
                  , "That is the number of edges. Nodes are the labeled circles in the picture above."
                  )
                , ( ""
                  , "Incorrect. Nodes are the labeled circles in the picture above. A node is still part of a graph even if it is not connected by an edge to any other nodes"
                  )
                ]
            , answer =
                ( toString (numberOfNodes model)
                , "Correct."
                )
            , format = FillInTheBlank
            }
        else if index == 2 then
            { question = "How many edges are in the graph above?"
            , distractors =
                [ ( toString (numberOfNodes model)
                  , "That is the number of nodes. Edges are the lines connecting circles in the picture above. A bi-directional edge (i.e., an edge with two arrows) still counts as a single edge."
                  )
                , ( ""
                  , "Incorrect. Edges are the lines connecting circles in the picture above. A bi-directional edge (i.e., an edge with two arrows) still counts as a single edge."
                  )
                ]
            , answer =
                ( toString (numberOfEdges model)
                , "Correct."
                )
            , format = FillInTheBlank
            }
        else if index == 3 then
            let
                f =
                    firstNode model

                l =
                    lastNode model

                ans =
                    pathExists model.graph f l

                actualPath =
                    Maybe.withDefault [] (genericSearch model.graph f l)

                fbackString =
                    if ans then
                        "One valid path is " ++ (toString actualPath)
                    else
                        "There is no path from Node " ++ toString (f) ++ " to Node " ++ toString (l)
            in
                { question = "True or False: There is a path from Node " ++ toString (f) ++ " to Node " ++ toString (l)
                , distractors =
                    [ ( toString (not ans)
                      , "Incorrect. " ++ fbackString
                      )
                    ]
                , answer =
                    ( toString ans
                    , "Correct. " ++ fbackString
                    )
                , format = MultipleChoice
                }
        else if index == 4 then
            let
                f =
                    randomNode model []

                l =
                    randomNode model [ f ]

                ans =
                    edgeExists model.graph f l

                opposite =
                    edgeExists model.graph l f

                fbackString =
                    if ans then
                        "There is an edge from Node " ++ toString (f) ++ " to Node " ++ toString (l)
                    else if opposite then
                        "There is an not an edge from Node "
                            ++ toString (f)
                            ++ " to Node "
                            ++ toString (l)
                            ++ ", but there is an edge from Node "
                            ++ toString (l)
                            ++ " to Node "
                            ++ toString (f)
                    else
                        "There is no edge between Node " ++ toString (f) ++ " and Node " ++ toString (l)
            in
                { question = "True or False: There is an edge from Node " ++ toString (f) ++ " to Node " ++ toString (l)
                , distractors =
                    [ ( toString (not ans)
                      , "Incorrect. " ++ fbackString
                      )
                    ]
                , answer =
                    ( toString ans
                    , "Correct. " ++ fbackString
                    )
                , format = MultipleChoice
                }
        else if index == 5 && directed then
            let
                n =
                    randomNode model []

                deg =
                    degree model.graph n

                inDeg =
                    inDegree model.graph n

                outDeg =
                    outDegree model.graph n
            in
                { question = "What is the in-degree of Node " ++ toString n ++ "?"
                , distractors =
                    [ ( toString deg
                      , "Incorrect. You identified the number of edges entering and leaving the node (the degree). You should only count the number of edges entering the node (the in-degree)"
                      )
                    , ( toString outDeg
                      , "Incorrect. You identified the number of edges leaving the node (the out-degree), not the number of edges entering the node (the in-degree)"
                      )
                    , ( toString (inDeg + outDeg)
                      , "Incorrect. You double-counted the bi-directional edges."
                      )
                    , ( ""
                      , "Incorrect. A node's in-degree is the number of edges entering (to) the node. A bidirectional node only is counted once."
                      )
                    ]
                , answer =
                    ( toString (inDeg)
                    , "Correct."
                    )
                , format = FillInTheBlank
                }
        else if index == 6 && directed then
            let
                n =
                    randomNode model []

                deg =
                    degree model.graph n

                inDeg =
                    inDegree model.graph n

                outDeg =
                    outDegree model.graph n
            in
                { question = "What is the out-degree of Node " ++ toString n ++ "?"
                , distractors =
                    [ ( toString deg
                      , "Incorrect. You identified the number of edges entering and leaving the node (the degree). You should only count the number of edges leaving the node (the out-degree)"
                      )
                    , ( toString inDeg
                      , "Incorrect. You identified the number of edges entering the node (the in-degree), not the number of edges leaving the node (the out-degree)"
                      )
                    , ( toString (inDeg + outDeg)
                      , "Incorrect. You double-counted the bi-directional edges."
                      )
                    , ( ""
                      , "Incorrect. A node's out-degree is the number of edges leaving (from) the node. A bidirectional node only is counted once."
                      )
                    ]
                , answer =
                    ( toString (outDeg)
                    , "Correct."
                    )
                , format = FillInTheBlank
                }
        else if index == 7 && weighted then
            let
                e =
                    randomEdge model

                f =
                    e.from

                t =
                    e.to

                weight =
                    e.weight
            in
                { question = "What is the weight of the edge from Node " ++ toString f ++ " to Node " ++ toString t ++ "?"
                , distractors =
                    [ ( ""
                      , "Incorrect. An edge's weight is the number displayed on top of (or next to) the edge."
                      )
                    ]
                , answer =
                    ( toString (weight)
                    , "Correct."
                    )
                , format = FillInTheBlank
                }
        else
            let
                n =
                    randomNode model []

                deg =
                    degree model.graph n

                inDeg =
                    inDegree model.graph n

                outDeg =
                    outDegree model.graph n
            in
                { question = "What is the degree of Node " ++ toString n ++ "?"
                , distractors =
                    [ ( toString inDeg
                      , "Incorrect. You identified the number of edges entering the node (the in-degree) but did not count the number of edges leaving the node (the out-degree)"
                      )
                    , ( toString outDeg
                      , "Incorrect. You identified the number of edges leaving the node (the out-degree) but did not count the number of edges entering the node (the in-degree)"
                      )
                    , ( toString (inDeg + outDeg)
                      , "Incorrect. You double-counted the bi-directional edges."
                      )
                    , ( ""
                      , "Incorrect. A node's degree is the number of edges entering (to) or exiting (from) the node. A bidirectional node only is only counted once."
                      )
                    ]
                , answer =
                    ( toString (deg)
                    , "Correct."
                    )
                , format = FillInTheBlank
                }


newQuestion : Model -> Int -> Model
newQuestion model index =
    let
        { nodes, edges, directed, weighted } =
            model.graph

        newQuestion =
            questionByIndex model index
    in
        { model | question = newQuestion, success = Nothing, userInput = "" }


checkAnswer : Model -> Model
checkAnswer model =
    let
        newHistory =
            List.take (historyLength - 1) model.history

        { question, distractors, answer } =
            model.question
    in
        if (fst answer) == model.userInput then
            { model | success = Just True, history = (Just True) :: newHistory, feedback = (snd answer) }
        else
            { model | success = Just False, history = (Just False) :: newHistory, feedback = (findFeedback (fst answer) model.userInput distractors) }


findFeedback : String -> String -> List ResponseAndFeedback -> String
findFeedback answer response distractors =
    case distractors of
        [] ->
            "Incorrect. The answer is " ++ answer

        d :: ds ->
            if ((fst d) == response || ((fst d) == "")) then
                (snd d) ++ " The answer is " ++ answer
            else
                findFeedback answer response ds
