module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Random exposing (..)
import Set exposing (..)
import String exposing (..)
import Debug exposing (..)
import Types exposing (..)
import View exposing (..)


-- MAIN


main : Program Never
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


init : ( Model, Cmd Msg )
init =
    update Reset initModel



-- VIEW


view : Model -> Html Msg
view model =
    let
        resetBtn =
            button [ onClick Reset ] [ Html.text "Reset" ]

        buttons =
            if model.debug then
                div []
                    [ resetBtn
                    , button [ onClick ToggleWeighted ] [ Html.text "Toggle Weighted" ]
                    , button [ onClick ToggleDirectional ] [ Html.text "Toggle Directional" ]
                    , button [ onClick BreadthFirstSearch ] [ Html.text "BFS" ]
                    ]
            else
                div [] [ resetBtn ]
    in
        div []
            [ h1 [ scoreboardStyle ] [ Html.text "Mastery Quiz" ]
            , imageOfGraph model
            , questionForm model
            , historySection model
            , buttons
            , p [] [ Html.text (toString model) ]
            ]


displayQuestion : Model -> Html Msg
displayQuestion model =
    let
        { question, distractors, answer, format } =
            model.question
    in
        case format of
            FillInTheBlank ->
                Html.form [ onSubmit Submit ]
                    [ div [] [ Html.text question ]
                    , input
                        [ Html.Attributes.type' "text"
                        , placeholder "Answer here..."
                        , onInput UserInput
                        , value model.userInput
                        ]
                        []
                    , button
                        [ Html.Attributes.type' "submit" ]
                        [ Html.text "Submit" ]
                    ]

            MultipleChoice ->
                -- let
                --     buttons =
                --         createButtons model
                -- in
                Html.form [ onSubmit Submit ]
                    [ div []
                        [ span [] [ Html.text question ]
                        , radio "True" model
                        , radio "False" model
                        ]
                    , button
                        [ Html.Attributes.type' "submit" ]
                        [ Html.text "Submit" ]
                    ]



-- createRadios : Model -> Html Msg
-- createRadios model =
--     let
--         rdo =


radio : String -> Model -> Html Msg
radio name model =
    let
        isSelected =
            model.userInput == name
    in
        label []
            [ br [] []
            , input [ Html.Attributes.type' "radio", checked isSelected, onCheck (\_ -> UserInput name) ] []
            , Html.text name
            ]


questionForm : Model -> Html Msg
questionForm model =
    let
        { question, distractors, answer, format } =
            model.question
    in
        case model.success of
            -- No answer has been submitted, so display the question
            Nothing ->
                displayQuestion model

            -- Answer has been submitted, so display the feedback
            Just _ ->
                Html.form [ onSubmit GiveFeedback ]
                    [ div [] [ Html.text model.feedback ]
                    , input
                        [ Html.Attributes.type' "text"
                        , placeholder "Answer here..."
                        , onInput UserInput
                        , value model.userInput
                        ]
                        []
                    , button
                        [ Html.Attributes.type' "submit" ]
                        [ Html.text "Next Question" ]
                    ]


imageOfGraph : Model -> Html Msg
imageOfGraph model =
    let
        graphWidth =
            ((viewConstants.nodeSeparation + viewConstants.nodeRadius) * viewConstants.nodesPerRow)

        graphHeight =
            ((viewConstants.nodeSeparation + viewConstants.nodeRadius) * viewConstants.nodesPerCol)
    in
        Svg.svg
            [ version "1.1"
            , baseProfile "full"
            , Svg.Attributes.width (toString graphWidth)
            , Svg.Attributes.height (toString graphHeight)
            ]
            (drawGraph model.graph)


drawGraph : Graph -> List (Svg a)
drawGraph graph =
    List.append (drawNodes graph) (drawEdges graph)


drawNodes : Graph -> List (Svg a)
drawNodes graph =
    let
        drawNodesHelper nodeIds =
            case nodeIds of
                [] ->
                    []

                id :: ids ->
                    List.append (drawNode id) (drawNodesHelper ids)
    in
        drawNodesHelper graph.nodes


nodeCol : NodeId -> Int
nodeCol nodeId =
    nodeId `rem` viewConstants.nodesPerCol


nodeX : NodeId -> Pixels
nodeX nodeId =
    let
        x0 =
            fst viewConstants.graphUpperLeft

        col =
            nodeId `rem` viewConstants.nodesPerCol
    in
        x0 + col * (viewConstants.nodeRadius + viewConstants.nodeSeparation)


sameCol : NodeId -> NodeId -> Bool
sameCol n1 n2 =
    (nodeX n1) == (nodeX n2)


nodeRow : NodeId -> Int
nodeRow nodeId =
    nodeId // viewConstants.nodesPerCol


nodeY : NodeId -> Pixels
nodeY nodeId =
    let
        y0 =
            snd viewConstants.graphUpperLeft

        row =
            nodeId // viewConstants.nodesPerCol
    in
        y0 + row * (viewConstants.nodeRadius + viewConstants.nodeSeparation)


sameRow : NodeId -> NodeId -> Bool
sameRow n1 n2 =
    (nodeY n1) == (nodeY n2)


drawNode : NodeId -> List (Svg a)
drawNode nodeId =
    [ Svg.circle
        [ cx (toString (nodeX nodeId))
        , cy (toString (nodeY nodeId))
        , r (toString viewConstants.nodeRadius)
        , fill "blue"
        ]
        []
    , Svg.text'
        [ x (toString (nodeX nodeId))
        , y (toString (nodeY nodeId))
        , Svg.Attributes.fontSize "14"
        , Svg.Attributes.textAnchor "middle"
        , fill "white"
        ]
        [ Svg.text (toString nodeId) ]
    ]


drawEdges : Graph -> List (Svg a)
drawEdges graph =
    let
        drawEdgesHelper edges weighted directional =
            case edges of
                [] ->
                    arrowHeads

                e :: es ->
                    List.append (drawEdge e weighted directional) (drawEdgesHelper es weighted directional)
    in
        drawEdgesHelper graph.edges graph.weighted graph.directional


drawEdge : Edge -> Bool -> Bool -> List (Svg a)
drawEdge edge weighted directional =
    let
        x_1 =
            nodeX edge.from

        y_1 =
            nodeY edge.from

        x_2 =
            nodeX edge.to

        y_2 =
            nodeY edge.to

        lne =
            [ edgeLine x_1 y_1 x_2 y_2 directional edge.direction ]
    in
        if weighted && (edge.weight > 0) then
            List.append lne [ edgeWeight edge.weight x_1 y_1 x_2 y_2 ]
        else
            lne


edgeWeight : EdgeWeight -> Pixels -> Pixels -> Pixels -> Pixels -> Svg a
edgeWeight weight x_1 y_1 x_2 y_2 =
    let
        xOffset =
            if (x_1 == x_2) then
                viewConstants.weightOffset
            else
                0

        yOffset =
            if (y_1 == y_2) then
                3 * viewConstants.weightOffset
            else
                0

        midX =
            ((x_1 + x_2) // 2) + xOffset

        midY =
            ((y_1 + y_2) // 2) + yOffset
    in
        Svg.text'
            [ x (toString (midX))
            , y (toString (midY))
            , Svg.Attributes.fontSize "18"
            , Svg.Attributes.textAnchor "middle"
            , fill "red"
            ]
            [ Svg.text (toString weight) ]


adjustPixel : Pixels -> Pixels -> Pixels
adjustPixel p1 p2 =
    if (p1 < p2) then
        p1 + viewConstants.nodeOffset
    else if (p1 == p2) then
        p1
    else
        p1 - viewConstants.nodeOffset


arrowHeads : List (Svg a)
arrowHeads =
    [ Svg.defs
        []
        [ Svg.marker
            [ Svg.Attributes.id "ArrowHeadEnd"
            , viewBox "0 0 10 10"
            , refX "1"
            , refY "5"
            , markerWidth "6"
            , markerHeight "6"
            , orient "auto"
            ]
            [ Svg.path
                [ d "M 0 0 L 10 5 L 0 10 z" ]
                []
            ]
        , Svg.marker
            [ Svg.Attributes.id "ArrowHeadStart"
            , viewBox "0 0 10 10"
            , refX "9"
            , refY "5"
            , markerWidth "6"
            , markerHeight "6"
            , orient "auto"
            ]
            [ Svg.path
                [ d "M 10 10 L 0 5 L 10 0 z" ]
                []
            ]
        ]
    ]


edgeLine : Pixels -> Pixels -> Pixels -> Pixels -> Bool -> ArrowDirection -> Svg a
edgeLine x_1 y_1 x_2 y_2 directional direction =
    let
        biArrow =
            [ markerStart "url(#ArrowHeadStart)"
            , markerEnd "url(#ArrowHeadEnd)"
            ]

        uniArrow =
            [ markerEnd "url(#ArrowHeadEnd)" ]

        lineStyle =
            [ x1 (toString (adjustPixel x_1 x_2))
            , y1 (toString (adjustPixel y_1 y_2))
            , x2 (toString (adjustPixel x_2 x_1))
            , y2 (toString (adjustPixel y_2 y_1))
            , fill "none"
            , stroke "black"
            , strokeWidth "2"
            ]

        lineStyle' =
            if directional && (direction == BiDirectional) then
                List.append lineStyle biArrow
            else if directional && (direction == UniDirectional) then
                List.append lineStyle uniArrow
            else
                lineStyle
    in
        Svg.line
            lineStyle'
            []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


updateGraph : Model -> List NodeId -> List Edge -> Bool -> Bool -> Model
updateGraph model ns es d w =
    { model | graph = { nodes = ns, edges = es, directional = d, weighted = w } }


closestNeighbor : List NodeId -> NodeId -> (NodeId -> NodeId -> Bool) -> Int -> Maybe NodeId
closestNeighbor allNodes fromNode pred offset =
    let
        closestNeighborHelper nodeId =
            if (nodeId < 0) || (nodeId >= viewConstants.nodesPerRow * viewConstants.nodesPerCol) then
                Nothing
            else if (List.member nodeId allNodes) && (pred fromNode nodeId) then
                Just nodeId
            else
                closestNeighborHelper (nodeId + offset)
    in
        closestNeighborHelper (fromNode + offset)



-- Given a node, find the closest nodes above, below, to the left and to
-- the right. If any of these doesn't exist, return a Nothing value


findNeighbors : List NodeId -> NodeId -> List (Maybe NodeId)
findNeighbors nodes node =
    [ closestNeighbor nodes node sameRow 1
    , closestNeighbor nodes node sameRow -1
    , closestNeighbor nodes node sameCol viewConstants.nodesPerRow
    , closestNeighbor nodes node sameCol -viewConstants.nodesPerRow
    ]



-- Given a list of maybes, return a list with only the values


stripList : List (Maybe a) -> List a
stripList maybes =
    case maybes of
        [] ->
            []

        (Just m) :: ms ->
            m :: (stripList ms)

        Nothing :: ms ->
            stripList ms



-- Given a node and a list of nodes it connects to, create edges
-- from the node to each of its neighbors


createEdgesFromNode : NodeId -> List NodeId -> List Edge
createEdgesFromNode fromNode neighbors =
    case neighbors of
        [] ->
            []

        n :: ns ->
            (Edge fromNode n 0 UniDirectional) :: (createEdgesFromNode fromNode ns)



-- Given a list of nodes, create all edges between each node such that:
-- * each edge is either horizontal or vertical
-- * edges don't pass through nodes


createAllEdges : List NodeId -> List Edge
createAllEdges nodes =
    let
        createAllEdgesHelper allNodes nodes =
            case nodes of
                [] ->
                    []

                n :: ns ->
                    List.append
                        (createEdgesFromNode n
                            (stripList (findNeighbors allNodes n))
                        )
                        (createAllEdgesHelper allNodes ns)
    in
        createAllEdgesHelper nodes nodes


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { nodes, edges, directional, weighted } =
            model.graph
    in
        case msg of
            Reset ->
                ( initModel, Random.generate NewRandomValues (Random.list 15 (Random.int 1 15)) )

            NewRandomValues newValues ->
                ( { model | randomValues = newValues }, Random.generate NewNodes (Random.list 15 (Random.int 1 15)) )

            NewNodes newNodes ->
                let
                    newNodes' =
                        Set.toList (Set.fromList newNodes)

                    newEdges =
                        (createAllEdges newNodes')
                in
                    ( updateGraph model newNodes' newEdges directional weighted
                    , Random.generate NewEdgeWeights (Random.list (List.length newEdges) (Random.int -1 5))
                    )

            NewEdgeWeights newWeights ->
                let
                    newEdges =
                        (replaceWeights edges newWeights)
                in
                    ( updateGraph model nodes newEdges directional weighted
                    , Random.generate NewQuestion (Random.int 4 4)
                    )

            NewQuestion questionIndex ->
                ( newQuestion model questionIndex, Cmd.none )

            ToggleWeighted ->
                ( updateGraph model nodes edges directional (not weighted), Cmd.none )

            ToggleDirectional ->
                ( updateGraph model nodes edges (not directional) weighted, Cmd.none )

            UserInput i ->
                ( { model | userInput = i }, Cmd.none )

            Submit ->
                if (String.isEmpty model.userInput) then
                    ( model, Cmd.none )
                else
                    ( checkAnswer model
                    , Cmd.none
                    )

            GiveFeedback ->
                ( model
                , Random.generate NewRandomValues (Random.list 15 (Random.int 1 15))
                )

            BreadthFirstSearch ->
                let
                    firstNode =
                        (List.head nodes)

                    lastNode =
                        (List.head (List.reverse nodes))
                in
                    case firstNode of
                        Nothing ->
                            ( model, Cmd.none )

                        Just start ->
                            case lastNode of
                                Nothing ->
                                    ( model, Cmd.none )

                                Just finish ->
                                    ( { model | bfs = (breadthFirstSearch model.graph start finish) }, Cmd.none )


questionByIndex : Model -> Int -> Question
questionByIndex model index =
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
    else
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


randomNode : Model -> List NodeId -> NodeId
randomNode model alreadyChosen =
    let
        graph =
            model.graph

        validNodes =
            model.randomValues
                |> List.filter (\n -> List.member n graph.nodes)
                |> List.filter (\n -> not (List.member n alreadyChosen))

        rNode =
            List.head validNodes
    in
        case rNode of
            Nothing ->
                0

            Just n ->
                n


newQuestion : Model -> Int -> Model
newQuestion model index =
    let
        { nodes, edges, directional, weighted } =
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



-- This function replaces the weights on each of the edges in a graph. Then it
-- removes all the edges with weights less than or equal to zero. Then it
-- merges each pair of matching unidirectional edges into a single
-- bi-directional edge


replaceWeights : List Edge -> List EdgeWeight -> List Edge
replaceWeights edges newWeights =
    newWeights
        -- create a new list of edges with new weights
        |>
            List.map2 (\e w -> { from = e.from, to = e.to, weight = w, direction = e.direction }) edges
        -- remove all edges with weight <= 0
        |>
            List.filter (\e -> e.weight > 0)
        -- merge matched edges into single bi-directional edges
        |>
            mergeDuplicates
        -- remove a vertical edge if it crosses a horizontal edge
        |>
            removeOverlappingEdges


mergeDuplicates : List Edge -> List Edge
mergeDuplicates edges =
    case edges of
        [] ->
            []

        e :: es ->
            let
                ( rev, notRev ) =
                    List.partition (\ee -> e.to == ee.from && e.from == ee.to) es
            in
                case rev of
                    [] ->
                        e :: mergeDuplicates notRev

                    r :: rs ->
                        { e | direction = BiDirectional } :: mergeDuplicates notRev


edgesOverlap : Edge -> Edge -> Bool
edgesOverlap e1 e2 =
    -- e1 is horizontal - in same row
    (sameRow e1.from e1.to)
        && -- e2 is vertical - in same column
           (sameCol e2.from e2.to)
        && -- row of e1 is between rows of e2
           ((nodeRow e2.from)
                < (nodeRow e1.from)
                && (nodeRow e1.from)
                < (nodeRow e2.to)
                || (nodeRow e2.to)
                < (nodeRow e1.from)
                && (nodeRow e1.from)
                < (nodeRow e2.from)
           )
        && -- col of e2 is between columns of e1
           ((nodeCol e1.from)
                < (nodeCol e2.from)
                && (nodeCol e2.from)
                < (nodeCol e1.to)
                || (nodeCol e1.to)
                < (nodeCol e2.from)
                && (nodeCol e2.from)
                < (nodeCol e1.from)
           )


removeOverlappingEdges : List Edge -> List Edge
removeOverlappingEdges edges =
    case edges of
        [] ->
            []

        e :: es ->
            let
                ( overlap, notOverlap ) =
                    List.partition (\ee -> (edgesOverlap e ee) || (edgesOverlap ee e)) es
            in
                e :: removeOverlappingEdges notOverlap


unwindSearchTree : List ( NodeId, List NodeId ) -> NodeId -> List NodeId
unwindSearchTree searchTree lastNode =
    case searchTree of
        [] ->
            []

        ( node, children ) :: rest ->
            if (List.member lastNode (Debug.log "kids" children)) then
                node :: (unwindSearchTree rest node)
            else
                unwindSearchTree rest lastNode


pathExists : Graph -> NodeId -> NodeId -> Bool
pathExists graph startNode endNode =
    let
        s =
            breadthFirstSearch graph startNode endNode
    in
        case s of
            Nothing ->
                False

            Just _ ->
                True


breadthFirstSearch : Graph -> NodeId -> NodeId -> Maybe (List NodeId)
breadthFirstSearch graph startNode endNode =
    genericSearch graph startNode endNode


genericSearch : Graph -> NodeId -> NodeId -> Maybe (List NodeId)
genericSearch graph startNode endNode =
    let
        searchHelper openList closedList searchTree =
            case openList of
                -- if the open list is empty then we're done
                [] ->
                    Nothing

                -- else pull the next item off the open list
                firstNode :: restOfList ->
                    --  if the next item is what we're looking for then
                    --  return the path
                    if (firstNode == endNode) then
                        Just (List.reverse (endNode :: (unwindSearchTree searchTree endNode)))
                    else
                        let
                            neighbors =
                                List.filter (edgeExists graph firstNode) graph.nodes
                                    |> List.filter (\n -> not (visited openList closedList n))

                            -- DFS put at start
                            -- BFS put at end
                            openList' =
                                (List.append restOfList neighbors)

                            searchTree' =
                                Debug.log "search tree: " (( firstNode, neighbors ) :: searchTree)

                            -- start again...
                        in
                            case neighbors of
                                [] ->
                                    (searchHelper openList' (firstNode :: closedList) searchTree')

                                _ ->
                                    (searchHelper openList' (firstNode :: closedList) searchTree')
    in
        searchHelper [ startNode ] [] []


visited : List NodeId -> List NodeId -> NodeId -> Bool
visited openList closedList node =
    (List.member node openList) || (List.member node closedList)


edgeExists : Graph -> NodeId -> NodeId -> Bool
edgeExists graph n1 n2 =
    let
        -- is there an edge (uni- or bi-directional) from n1 to n2
        n1_to_n2 =
            List.any (\e -> e.from == n1 && e.to == n2) graph.edges

        -- is there a bidirectional edge from n2 to n1
        n2_to_n1_bi =
            List.any (\e -> e.from == n2 && e.to == n1 && e.direction == BiDirectional) graph.edges

        -- the graph is non-directional and there is an edge from n2 to n1
        n2_to_n1_non =
            (not graph.directional) && List.any (\e -> e.from == n2 && e.to == n1) graph.edges
    in
        n1_to_n2 || n2_to_n1_bi || n2_to_n1_non


numberOfNodes : Model -> Int
numberOfNodes model =
    let
        { nodes, edges, directional, weighted } =
            model.graph
    in
        List.length nodes


numberOfEdges : Model -> Int
numberOfEdges model =
    let
        { nodes, edges, directional, weighted } =
            model.graph
    in
        List.length edges


firstNode : Model -> NodeId
firstNode model =
    let
        { nodes, edges, directional, weighted } =
            model.graph
    in
        case nodes of
            [] ->
                0

            n :: ns ->
                n


lastNode : Model -> NodeId
lastNode model =
    let
        { nodes, edges, directional, weighted } =
            model.graph

        nodes' =
            List.reverse nodes
    in
        case nodes' of
            [] ->
                0

            n :: ns ->
                n
