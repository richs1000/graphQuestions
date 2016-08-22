module QuestionTypes exposing (..)


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
