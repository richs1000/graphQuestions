module Question exposing (..)

import Graph exposing (..)
import Search exposing (..)


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



-- questionByIndex : Model -> Int -> Question
-- questionByIndex model index =
--     let
--         { nodes, edges, directed, weighted } =
--             model.graph
--     in
--         if index == 1 then
--             { question = "How many nodes are in the graph above?"
--             , distractors =
--                 [ ( toString (numberOfEdges model.graph)
--                   , "That is the number of edges. Nodes are the labeled circles in the picture above."
--                   )
--                 , ( ""
--                   , "Incorrect. Nodes are the labeled circles in the picture above. A node is still part of a graph even if it is not connected by an edge to any other nodes"
--                   )
--                 ]
--             , answer =
--                 ( toString (numberOfNodes model.graph)
--                 , "Correct."
--                 )
--             , format = FillInTheBlank
--             }
--         else if index == 2 then
--             { question = "How many edges are in the graph above?"
--             , distractors =
--                 [ ( toString (numberOfNodes model.graph)
--                   , "That is the number of nodes. Edges are the lines connecting circles in the picture above. A bi-directional edge (i.e., an edge with two arrows) still counts as a single edge."
--                   )
--                 , ( ""
--                   , "Incorrect. Edges are the lines connecting circles in the picture above. A bi-directional edge (i.e., an edge with two arrows) still counts as a single edge."
--                   )
--                 ]
--             , answer =
--                 ( toString (numberOfEdges model.graph)
--                 , "Correct."
--                 )
--             , format = FillInTheBlank
--             }
--         else if index == 3 then
--             let
--                 f =
--                     firstNode model.graph
--
--                 l =
--                     lastNode model.graph
--
--                 ans =
--                     pathExists model.graph f l
--
--                 actualPath =
--                     Maybe.withDefault [] (genericSearch model.graph f l)
--
--                 fbackString =
--                     if ans then
--                         "One valid path is " ++ (toString actualPath)
--                     else
--                         "There is no path from Node " ++ toString (f) ++ " to Node " ++ toString (l)
--             in
--                 { question = "True or False: There is a path from Node " ++ toString (f) ++ " to Node " ++ toString (l)
--                 , distractors =
--                     [ ( toString (not ans)
--                       , "Incorrect. " ++ fbackString
--                       )
--                     ]
--                 , answer =
--                     ( toString ans
--                     , "Correct. " ++ fbackString
--                     )
--                 , format = MultipleChoice
--                 }
--         else if index == 4 then
--             let
--                 f =
--                     randomNode model.graph model.randomValues []
--
--                 l =
--                     randomNode model.graph model.randomValues [ f ]
--
--                 ans =
--                     edgeExists model.graph f l
--
--                 opposite =
--                     edgeExists model.graph l f
--
--                 fbackString =
--                     if ans then
--                         "There is an edge from Node " ++ toString (f) ++ " to Node " ++ toString (l)
--                     else if opposite then
--                         "There is an not an edge from Node "
--                             ++ toString (f)
--                             ++ " to Node "
--                             ++ toString (l)
--                             ++ ", but there is an edge from Node "
--                             ++ toString (l)
--                             ++ " to Node "
--                             ++ toString (f)
--                     else
--                         "There is no edge between Node " ++ toString (f) ++ " and Node " ++ toString (l)
--             in
--                 { question = "True or False: There is an edge from Node " ++ toString (f) ++ " to Node " ++ toString (l)
--                 , distractors =
--                     [ ( toString (not ans)
--                       , "Incorrect. " ++ fbackString
--                       )
--                     ]
--                 , answer =
--                     ( toString ans
--                     , "Correct. " ++ fbackString
--                     )
--                 , format = MultipleChoice
--                 }
--         else if index == 5 && directed then
--             let
--                 n =
--                     randomNode model.graph model.randomValues []
--
--                 deg =
--                     degree model.graph n
--
--                 inDeg =
--                     inDegree model.graph n
--
--                 outDeg =
--                     outDegree model.graph n
--             in
--                 { question = "What is the in-degree of Node " ++ toString n ++ "?"
--                 , distractors =
--                     [ ( toString deg
--                       , "Incorrect. You identified the number of edges entering and leaving the node (the degree). You should only count the number of edges entering the node (the in-degree)"
--                       )
--                     , ( toString outDeg
--                       , "Incorrect. You identified the number of edges leaving the node (the out-degree), not the number of edges entering the node (the in-degree)"
--                       )
--                     , ( toString (inDeg + outDeg)
--                       , "Incorrect. You double-counted the bi-directional edges."
--                       )
--                     , ( ""
--                       , "Incorrect. A node's in-degree is the number of edges entering (to) the node. A bidirectional node only is counted once."
--                       )
--                     ]
--                 , answer =
--                     ( toString (inDeg)
--                     , "Correct."
--                     )
--                 , format = FillInTheBlank
--                 }
--         else if index == 6 && directed then
--             let
--                 n =
--                     randomNode model.graph model.randomValues []
--
--                 deg =
--                     degree model.graph n
--
--                 inDeg =
--                     inDegree model.graph n
--
--                 outDeg =
--                     outDegree model.graph n
--             in
--                 { question = "What is the out-degree of Node " ++ toString n ++ "?"
--                 , distractors =
--                     [ ( toString deg
--                       , "Incorrect. You identified the number of edges entering and leaving the node (the degree). You should only count the number of edges leaving the node (the out-degree)"
--                       )
--                     , ( toString inDeg
--                       , "Incorrect. You identified the number of edges entering the node (the in-degree), not the number of edges leaving the node (the out-degree)"
--                       )
--                     , ( toString (inDeg + outDeg)
--                       , "Incorrect. You double-counted the bi-directional edges."
--                       )
--                     , ( ""
--                       , "Incorrect. A node's out-degree is the number of edges leaving (from) the node. A bidirectional node only is counted once."
--                       )
--                     ]
--                 , answer =
--                     ( toString (outDeg)
--                     , "Correct."
--                     )
--                 , format = FillInTheBlank
--                 }
--         else if index == 7 && weighted then
--             let
--                 e =
--                     randomEdge model.graph model.randomValues
--
--                 f =
--                     e.from
--
--                 t =
--                     e.to
--
--                 weight =
--                     e.weight
--             in
--                 { question = "What is the weight of the edge from Node " ++ toString f ++ " to Node " ++ toString t ++ "?"
--                 , distractors =
--                     [ ( ""
--                       , "Incorrect. An edge's weight is the number displayed on top of (or next to) the edge."
--                       )
--                     ]
--                 , answer =
--                     ( toString (weight)
--                     , "Correct."
--                     )
--                 , format = FillInTheBlank
--                 }
--         else
--             let
--                 n =
--                     randomNode model.graph model.randomValues []
--
--                 deg =
--                     degree model.graph n
--
--                 inDeg =
--                     inDegree model.graph n
--
--                 outDeg =
--                     outDegree model.graph n
--             in
--                 { question = "What is the degree of Node " ++ toString n ++ "?"
--                 , distractors =
--                     [ ( toString inDeg
--                       , "Incorrect. You identified the number of edges entering the node (the in-degree) but did not count the number of edges leaving the node (the out-degree)"
--                       )
--                     , ( toString outDeg
--                       , "Incorrect. You identified the number of edges leaving the node (the out-degree) but did not count the number of edges entering the node (the in-degree)"
--                       )
--                     , ( toString (inDeg + outDeg)
--                       , "Incorrect. You double-counted the bi-directional edges."
--                       )
--                     , ( ""
--                       , "Incorrect. A node's degree is the number of edges entering (to) or exiting (from) the node. A bidirectional node only is only counted once."
--                       )
--                     ]
--                 , answer =
--                     ( toString (deg)
--                     , "Correct."
--                     )
--                 , format = FillInTheBlank
--                 }


newQuestion : Graph -> List Int -> Int -> Question
newQuestion graph randomValues index =
    let
        { nodes, edges, directed, weighted } =
            graph
    in
        if index == 1 then
            { question = "How many nodes are in the graph above?"
            , distractors =
                [ ( toString (numberOfEdges graph)
                  , "That is the number of edges. Nodes are the labeled circles in the picture above."
                  )
                , ( ""
                  , "Incorrect. Nodes are the labeled circles in the picture above. A node is still part of a graph even if it is not connected by an edge to any other nodes"
                  )
                ]
            , answer =
                ( toString (numberOfNodes graph)
                , "Correct."
                )
            , format = FillInTheBlank
            }
        else if index == 2 then
            { question = "How many edges are in the graph above?"
            , distractors =
                [ ( toString (numberOfNodes graph)
                  , "That is the number of nodes. Edges are the lines connecting circles in the picture above. A bi-directional edge (i.e., an edge with two arrows) still counts as a single edge."
                  )
                , ( ""
                  , "Incorrect. Edges are the lines connecting circles in the picture above. A bi-directional edge (i.e., an edge with two arrows) still counts as a single edge."
                  )
                ]
            , answer =
                ( toString (numberOfEdges graph)
                , "Correct."
                )
            , format = FillInTheBlank
            }
        else if index == 3 then
            let
                f =
                    firstNode graph

                l =
                    lastNode graph

                ans =
                    pathExists graph f l

                actualPath =
                    Maybe.withDefault [] (genericSearch graph f l)

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
                    randomNode graph randomValues []

                l =
                    randomNode graph randomValues [ f ]

                ans =
                    edgeExists graph f l

                opposite =
                    edgeExists graph l f

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
                    randomNode graph randomValues []

                deg =
                    degree graph n

                inDeg =
                    inDegree graph n

                outDeg =
                    outDegree graph n
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
                    randomNode graph randomValues []

                deg =
                    degree graph n

                inDeg =
                    inDegree graph n

                outDeg =
                    outDegree graph n
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
                    randomEdge graph randomValues

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
                    randomNode graph randomValues []

                deg =
                    degree graph n

                inDeg =
                    inDegree graph n

                outDeg =
                    outDegree graph n
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



-- newQuestion : Model -> Int -> Model
-- newQuestion model index =
--     let
--         { nodes, edges, directed, weighted } =
--             model.graph
--
--         newQuestion =
--             questionByIndex model index
--     in
--         { model | question = newQuestion, success = Nothing, userInput = "" }


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
