module GraphQuestions exposing (..)

import Html.App as Html
import Types exposing (Model, Msg(..))
import View exposing (view)
import Ports exposing (..)
import Update exposing (update)
import Model exposing (init)


-- MAIN


main : Program Never
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL
-- VIEW
-- PORTS
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    ssData GetValuesFromSS



-- UPDATE
