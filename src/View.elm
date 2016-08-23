module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ModelType exposing (..)
import GraphView exposing (..)
import HistoryView exposing (..)
import QuestionView exposing (..)
import MessageTypes exposing (..)


scoreboardStyle : Html.Attribute msg
scoreboardStyle =
    Html.Attributes.style
        [ ( "border-top", "1px solid #000" )
        , ( "border-bottom", "1px solid #000" )
        , ( "background", "#ffffcc" )
        , ( "height", "40px" )
        , ( "margin-left", "6px" )
        , ( "margin-right", "6px" )
        ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [ scoreboardStyle ] [ Html.text "Test Your Understanding" ]
        , imageOfGraph model.graph
        , questionOrFeedback model
        , historySection model.history model.denominator
        , debugSection model
        ]


questionOrFeedback : Model -> Html Msg
questionOrFeedback model =
    case model.success of
        -- No answer has been submitted, so display the question
        Nothing ->
            displayQuestion model.question model.userInput (Maybe.withDefault 0 (List.head model.randomValues))

        -- Answer has been submitted, so display the feedback
        Just _ ->
            displayFeedback model.userInput model.feedback


debugSection : Model -> Html Msg
debugSection model =
    if model.debug then
        div []
            [ button [ onClick Reset, buttonStyle ] [ Html.text "Reset" ]
            , button [ onClick ToggleWeighted, buttonStyle ] [ Html.text "Toggle Weighted" ]
            , button [ onClick ToggleDirectional, buttonStyle ] [ Html.text "Toggle Directional" ]
            , button [ onClick BreadthFirstSearch, buttonStyle ] [ Html.text "BFS" ]
            , button [ onClick UpdateMastery, buttonStyle ] [ Html.text "Mastery" ]
            , p [] [ Html.text (toString model) ]
            ]
    else
        div [] []
