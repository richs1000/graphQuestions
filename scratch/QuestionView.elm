module QuestionView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Messages exposing (..)


questionForm : Model -> Html Msg
questionForm model =
    Html.form [ onSubmit Submit ]
        [ div [] [ Html.text (questionString model) ]
        , input
            [ Html.Attributes.type' "text"
            , placeholder "Answer here..."
            , onInput Respond
            , value model.response
            ]
            []
        , button
            [ Html.Attributes.type' "submit" ]
            [ Html.text "Submit" ]
        ]


questionString : Model -> String
questionString model =
    "How many nodes does this graph have?"
