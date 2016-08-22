module Model exposing (..)

import Types exposing (Model, Msg)
import Graph exposing (emptyGraph)
import Question exposing (emptyQuestion)


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
