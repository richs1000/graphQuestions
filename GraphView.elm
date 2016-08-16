module GraphView exposing (..)

import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import View exposing (..)
import Types exposing (..)


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
