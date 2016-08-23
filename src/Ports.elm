port module Ports exposing (..)

-- import Types exposing (..)

import MessageTypes exposing (SSData)


-- Sends mastery flag out to JS


port updateMastery : Bool -> Cmd msg



-- Receives values from Smart Sparrow


port ssData : (SSData -> msg) -> Sub msg
