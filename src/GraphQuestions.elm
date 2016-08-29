module GraphQuestions exposing (..)

import Html.App as Html
import ModelType exposing (Model)
import View exposing (view)
import Ports exposing (..)
import Update exposing (update)
import Model exposing (init)
import MessageTypes exposing (Msg(..))


main : Program Never
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    ssData GetValuesFromSS
