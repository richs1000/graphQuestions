module QuestionView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)
import QuestionTypes exposing (..)


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


displayQuestion : Model -> Html Msg
displayQuestion model =
    let
        { question, distractors, answer, format } =
            model.question
    in
        case format of
            FillInTheBlank ->
                Html.form [ onSubmit Submit ]
                    [ div [ questionStyle ] [ Html.text question ]
                    , input
                        [ Html.Attributes.type' "text"
                        , placeholder "Answer here..."
                        , onInput UserInput
                        , value model.userInput
                        , inputStyle
                        ]
                        []
                    , button
                        [ Html.Attributes.type' "submit"
                        , buttonStyle
                        ]
                        [ Html.text "Submit" ]
                    ]

            MultipleChoice ->
                Html.form [ onSubmit Submit ]
                    [ div [ questionStyle ] [ Html.text question ]
                    , div []
                        [ radio "True" model
                        , radio "False" model
                        ]
                    , button
                        [ Html.Attributes.type' "submit"
                        , buttonStyle
                        ]
                        [ Html.text "Submit" ]
                    ]


radio : String -> Model -> Html Msg
radio name model =
    let
        isSelected =
            model.userInput == name
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


questionForm : Model -> Html Msg
questionForm model =
    let
        { question, distractors, answer, format } =
            model.question

        success' =
            model.success
    in
        case model.success of
            -- No answer has been submitted, so display the question
            Nothing ->
                displayQuestion model

            -- Answer has been submitted, so display the feedback
            Just _ ->
                Html.form [ onSubmit GiveFeedback ]
                    [ div [ questionStyle ] [ Html.text model.feedback ]
                    , input
                        [ Html.Attributes.type' "text"
                        , placeholder "Answer here..."
                        , onInput UserInput
                        , value model.userInput
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
