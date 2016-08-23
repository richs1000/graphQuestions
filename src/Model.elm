module Model exposing (..)

import Types exposing (Model)
import MessageTypes exposing (Msg(..))
import Graph exposing (emptyGraph)
import Question exposing (emptyQuestion)


masteryAchieved : Model -> Bool
masteryAchieved model =
    let
        correctAnswers =
            Debug.log "in masteryAchieved "
                List.foldr
                (\h acc ->
                    if h == Just True then
                        acc + 1
                    else
                        acc
                )
                0
                model.history
    in
        if model.implementMastery then
            correctAnswers >= model.numerator
        else
            (List.length model.history) >= model.numerator


initModel : Model
initModel =
    { graph = emptyGraph
    , debug = True
    , userInput = ""
    , history = []
    , bfs = Nothing
    , success = Nothing
    , question = emptyQuestion
    , feedback = ""
    , randomValues = []
    , mastery = False
    , numerator = 3
    , denominator = 5
    , implementMastery = False
    }


init : ( Model, Cmd Msg )
init =
    -- update Reset initModel
    ( initModel, Cmd.none )
