module GraphView exposing (..)

import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Graph exposing (..)
import MessageTypes exposing (Msg(..))


type alias Pixels =
    Int


nodeSeparation : Pixels
nodeSeparation =
    100


nodeRadius : Pixels
nodeRadius =
    20


nodeOffset : Pixels
nodeOffset =
    30


weightOffset : Pixels
weightOffset =
    7


graphUpperLeft : ( Pixels, Pixels )
graphUpperLeft =
    ( 40, 20 )


drawGraph : Graph -> List (Svg a)
drawGraph graph =
    List.append (drawNodes graph) (drawEdges graph)


imageOfGraph : Graph -> Html Msg
imageOfGraph graph =
    let
        graphWidth =
            ((nodeSeparation + nodeRadius) * graph.nodesPerRow)

        graphHeight =
            ((nodeSeparation + nodeRadius)
                * (graph.nodesPerCol - 1)
                + nodeRadius
                + (nodeSeparation // 2)
            )
    in
        Svg.svg
            [ version "1.1"
            , baseProfile "full"
            , Svg.Attributes.width (toString graphWidth)
            , Svg.Attributes.height (toString graphHeight)
            ]
            (drawGraph graph)


drawNodes : Graph -> List (Svg a)
drawNodes graph =
    let
        drawNodesHelper nodeIds =
            case nodeIds of
                [] ->
                    []

                id :: ids ->
                    List.append (drawNode graph id) (drawNodesHelper ids)
    in
        drawNodesHelper graph.nodes


nodeX : Graph -> NodeId -> Pixels
nodeX graph nodeId =
    let
        x0 =
            fst graphUpperLeft

        col =
            nodeId `rem` graph.nodesPerCol
    in
        x0 + col * (nodeRadius + nodeSeparation)


nodeY : Graph -> NodeId -> Pixels
nodeY graph nodeId =
    let
        y0 =
            snd graphUpperLeft

        row =
            nodeId // graph.nodesPerCol
    in
        y0 + row * (nodeRadius + nodeSeparation)


drawNode : Graph -> NodeId -> List (Svg a)
drawNode graph nodeId =
    [ Svg.circle
        [ cx (toString (nodeX graph nodeId))
        , cy (toString (nodeY graph nodeId))
        , r (toString nodeRadius)
        , fill "blue"
        ]
        []
    , Svg.text'
        [ x (toString (nodeX graph nodeId))
        , y (toString (nodeY graph nodeId))
        , Svg.Attributes.fontSize "14"
        , Svg.Attributes.textAnchor "middle"
        , fill "white"
        ]
        [ Svg.text (toString nodeId) ]
    ]


drawEdges : Graph -> List (Svg a)
drawEdges graph =
    let
        drawEdgesHelper edges weighted directed =
            case edges of
                [] ->
                    arrowHeads

                e :: es ->
                    List.append (drawEdge graph e weighted directed) (drawEdgesHelper es weighted directed)
    in
        drawEdgesHelper graph.edges graph.weighted graph.directed


drawEdge : Graph -> Edge -> Bool -> Bool -> List (Svg a)
drawEdge graph edge weighted directed =
    let
        x_1 =
            nodeX graph edge.from

        y_1 =
            nodeY graph edge.from

        x_2 =
            nodeX graph edge.to

        y_2 =
            nodeY graph edge.to

        lne =
            [ edgeLine x_1 y_1 x_2 y_2 directed edge.direction ]
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
                weightOffset
            else
                0

        yOffset =
            if (y_1 == y_2) then
                3 * weightOffset
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
        p1 + nodeOffset
    else if (p1 == p2) then
        p1
    else
        p1 - nodeOffset


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
edgeLine x_1 y_1 x_2 y_2 directed direction =
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
            if directed && (direction == BiDirectional) then
                List.append lineStyle biArrow
            else if directed && (direction == UniDirectional) then
                List.append lineStyle uniArrow
            else
                lineStyle
    in
        Svg.line
            lineStyle'
            []
