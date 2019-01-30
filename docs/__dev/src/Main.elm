port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode

import AudioGraph exposing (..)
import AudioGraph.Units exposing (..)
import AudioGraph.Encode exposing (encodeGraph)

-- ---------------------------
-- MAIN
-- ---------------------------


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "elm-audio-graph-demo"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        }


-- ---------------------------
-- PORTS
-- ---------------------------


port broadcastAudioGraph : Encode.Value -> Cmd msg


-- ---------------------------
-- MODEL
-- ---------------------------


type alias Model =
  { graph : AudioGraph
  }


init : () -> ( Model, Cmd Msg )
init _ = 
  let 
    graph =
      createAudioGraph
      |> setNode "oscA" createOscillatorNode
      |> setNode "oscB" (createOscillatorNode
        |> updateParam "frequency" (Hertz 6))
      |> setNode "gain" (createGainNode
        |> updateParam "gain" (Number 0.25))
      |> addConnection (connect "oscA" 0 "gain" (InputChannel 0))
      |> addConnection (connect "oscB" 0 "gain" (InputParam "gain"))
      |> addConnection (connect "gain" 0 "__destination" (InputChannel 0))
  in
    update BroadcastGraph { graph = graph }


-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
   = BroadcastGraph

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    BroadcastGraph ->
      ( model, broadcastAudioGraph (encodeGraph model.graph) )


-- ---------------------------
-- VIEW
-- --------------------------


view : Model -> Html Msg
view model =
  div [] []