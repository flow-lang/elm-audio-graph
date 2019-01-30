port module Main exposing (..)

import AudioGraph exposing (..)
import AudioGraph.Encode exposing (encodeGraph)
import AudioGraph.Units exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Markdown



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


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col" ] [ content ] 
            ]
        ]


content : Html msg
content =
    Markdown.toHtml [ class "content" ] """
# elm-audio-graph

Psst. Here to learn how to make kickass web audio apps with Elm?
Awesome! To get started we need to create an empty audio graph. The
audio graph is where we store all of our audio nodes and keep track
of how they're connected to each other.

```elm
import AudioGraph exposing ( createGraph )

graph = createGraph
```

Well that wasn't exactly Earth-shattering. To actually make some noise
we need to create some audio nodes and connect them together. Let's start
with a basic sine oscillator that we'll connect to our speakers.
 
```elm
import AudioGraph exposing
  ( createGraph           -- Creates the audio graph
  , createOscillatorNode  -- Creates an oscillator node
  , addNode               -- Adds a node to the graph
  , addConnection         -- Adds a connection to the graph
  , connect               -- Creates a connection between two nodes
  , NodeInput (..)        -- Specifies what type of input to connect to
  )

graph =
  createGraph
    |> addNode "myOsc" createOscillatorNode
    |> addConnection (connect "myOsc" 0 "__destination" (InputChannel 0))
```

Now we're making some noise but we've just added a lot of
new stuff, what does it all do?

* First, we create a new audio graph as before.
* Then, we say we want to add a node to the graph, and give
  it an id of "myOsc". The id is important because it lets
  us track changes and updates to a node.
* We also need to supply the node we want to add. createOscillatorNode
  returns a new oscilator node with some sensible default values. 
* Then we add a connection just like we added the node. We need to actually
  do the connection too. Here we connect our oscillator by supplying the id
  we created before, "myOsc", and an output channel of 0 and then the id
  of the node we want to connect to. "__destination" is a special node that
  gets created for us when we call createGraph and it represents our speakers
  or some other final output for the graph.
"""