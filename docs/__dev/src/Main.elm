port module Main exposing (Model, Msg(..), broadcastAudioGraph, codeSnippet_01, init, main, update, view)

import AudioGraph exposing (..)
import AudioGraph.Encode exposing (encodeGraph)
import AudioGraph.Units exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode



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
                |> setNode "oscB"
                    (createOscillatorNode
                        |> updateParam "frequency" (Hertz 6)
                    )
                |> setNode "gain"
                    (createGainNode
                        |> updateParam "gain" (Number 0.25)
                    )
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


codeSnippet_01 : String
codeSnippet_01 =
    """import AudioGraph exposing ( createGraph )

graph = createGraph"""

codeSnippet_02 : String
codeSnippet_02 =
    """import AudioGraph exposing
  ( createGraph           -- Creates the audio graph
  , createOscillatorNode  -- Creates an oscillator node
  , addNode               -- Adds a node to the graph
  , addConnection         -- Adds a connection to the graph
  , connect               -- Creates a connection between two nodes
  , NodeInput (..)        -- Specifies what type of input to connect to
  )

graph =
  createGraph
    |> addNode \"myOsc\" createOscillatorNode
    |> addConnection (connect \"myOsc\" 0 \"__destination\" (InputChannel 0))"""


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col" ]
                [ h1 [ class "title" ]
                    [ text "elm-audio-graph" ]
                , p [ class "content" ]
                    [ text
                        """
                        Psst. Here to learn how to make kickass web audio apps with Elm?
                        Awesome! To get started we need to create an empty audio graph. The
                        audio graph is where we store all of our audio nodes and keep track
                        of how they're connected to each other.
                        """
                    , pre [] [ text codeSnippet_01 ]
                    , text
                        """
                        Well that wasn't exactly Earth-shattering. To actually make some noise
                        we need to create some audio nodes and connect them together. Let's start
                        with a basic sine oscillator that we'll connect to our speakers.
                        """
                    , pre [] [ text codeSnippet_02 ]
                    , text
                        """
                        Now we're making some noise but we've just added a lot of
                        new stuff, what does it all do?
                        """
                    ]
                ]
            ]
        ]
