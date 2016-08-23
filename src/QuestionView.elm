module QuestionView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Question exposing (..)
import MessageTypes exposing (Msg(..))


questionStyle : Html.Attribute msg
questionStyle =
    Html.Attributes.style
        [ ( "width", "100%" )
          -- , ( "height", "40px" )
        , ( "padding", "10px" )
        , ( "font-size", "2em" )
        , ( "margin", "4px" )
          -- , ( "line-height", "3" )
        ]


radioStyle : Html.Attribute msg
radioStyle =
    Html.Attributes.style
        [ ( "width", "40px" )
        , ( "height", "40px" )
        , ( "border-radius", "50%" )
        ]


inputStyle : Html.Attribute msg
inputStyle =
    Html.Attributes.style
        [ ( "width", "100%" )
        , ( "height", "40px" )
        , ( "padding", "10px" )
        , ( "font-size", "2em" )
        , ( "margin", "8px" )
        ]


buttonStyle : Html.Attribute msg
buttonStyle =
    Html.Attributes.style
        [ ( "text-align", "center" )
        , ( "font-size", "16px" )
        , ( "padding", "15px 32px" )
        , ( "margin", "2px" )
        ]


fillInTheBlank : Question -> String -> Html Msg
fillInTheBlank quest userInput =
    Html.form [ onSubmit Submit ]
        [ div [ questionStyle ] [ Html.text quest.question ]
        , input
            [ Html.Attributes.type' "text"
            , placeholder "Answer here..."
            , onInput UserInput
            , value userInput
            , inputStyle
            ]
            []
        , button
            [ Html.Attributes.type' "submit"
            , buttonStyle
            ]
            [ Html.text "Submit" ]
        ]


multipleChoiceButtons : ResponseAndFeedback -> List ResponseAndFeedback -> String -> Int -> Html Msg
multipleChoiceButtons answer distractors userInput randomValue =
    let
        answerPosition =
            randomValue `rem` (1 + (List.length distractors))

        allItems =
            (List.drop answerPosition distractors)
                |> List.append [ answer ]
                |> List.append (List.take answerPosition distractors)

        -- |> List.append answer
        -- |> List.append (List.take answerPosition distractors)
        radios =
            List.foldl (\i acc -> (radio (fst i) userInput) :: acc) [] allItems
    in
        div []
            radios


multipleChoice : Question -> String -> Int -> Html Msg
multipleChoice quest userInput randomValue =
    Html.form [ onSubmit Submit ]
        [ div [ questionStyle ] [ Html.text quest.question ]
        , (multipleChoiceButtons quest.answer quest.distractors userInput randomValue)
        , button
            [ Html.Attributes.type' "submit"
            , buttonStyle
            ]
            [ Html.text "Submit" ]
        ]


displayQuestion : Question -> String -> Int -> Html Msg
displayQuestion quest userInput randomValue =
    case quest.format of
        FillInTheBlank ->
            fillInTheBlank quest userInput

        MultipleChoice ->
            multipleChoice quest userInput randomValue


radio : String -> String -> Html Msg
radio name userInput =
    let
        isSelected =
            userInput == name
    in
        label []
            [ br [] []
            , input
                [ Html.Attributes.type' "radio"
                , checked isSelected
                , onCheck (\_ -> UserInput name)
                , radioStyle
                ]
                []
            , span [ questionStyle ] [ Html.text name ]
            ]


displayFeedback : String -> String -> Html Msg
displayFeedback userInput feedback =
    Html.form [ onSubmit GiveFeedback ]
        [ div [ questionStyle ] [ Html.text feedback ]
        , input
            [ Html.Attributes.type' "text"
            , value userInput
            , disabled True
            , inputStyle
            ]
            []
        , button
            [ Html.Attributes.type' "submit"
            , buttonStyle
            ]
            [ Html.text "Next Question" ]
        ]
