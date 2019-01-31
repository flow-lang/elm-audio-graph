port module Main exposing (main)

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
    update BroadcastGraph { graph = createAudioGraph }



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = BroadcastGraph
    | Example_0
    | Example_1
    | Example_2 Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BroadcastGraph ->
            ( model, broadcastAudioGraph (encodeGraph model.graph) )

        Example_0 ->
            createAudioGraph
                |> (\g -> update BroadcastGraph { graph = g })

        Example_1 ->
            model.graph
                |> setNode "myOsc" createOscillatorNode
                |> addConnection (connect "myOsc" 0 "__destination" (InputChannel 0))
                |> (\g -> update BroadcastGraph { graph = g })

        Example_2 freq ->
            model.graph
                |> getNode "myOsc"
                |> Maybe.map (updateParam "frequency" (Hertz freq))
                |> (\n -> Maybe.map2 (setNode "myOsc") n (Just model.graph))
                |> Maybe.withDefault model.graph
                |> (\g -> update BroadcastGraph { graph = g })



-- ---------------------------
-- VIEW
-- --------------------------


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row section" ]
            [ div [ class "col" ] contentA ]
        ]


contentA : List (Html Msg)
contentA =
    [ Markdown.toHtml [ class "content" ] """
# elm-audio-graph

Psst. Here to learn how to make kickass web audio apps with Elm?
Awesome! To get started we need to create an empty audio graph. The
audio graph is where we store all of our audio nodes and keep track
of how they're connected to each other.

```elm
import AudioGraph exposing ( createAudioGraph )

graph = createAudioGraph
```
"""
    , button [ class "button", onClick Example_0 ] [ text "Run" ]
    , Markdown.toHtml [ class "content" ] """
Well that wasn't exactly Earth-shattering. To actually make some noise
we need to create some audio nodes and connect them together. Let's start
with a basic sine oscillator that we'll connect to our speakers.
 
```elm
import AudioGraph exposing
  ( createAudioGraph      -- Creates the audio graph
  , createOscillatorNode  -- Creates an oscillator node
  , setNode               -- Adds a node to the graph
  , addConnection         -- Adds a connection to the graph
  , connect               -- Creates a connection between two nodes
  , NodeInput (..)        -- Specifies what type of input to connect to
  )

graph =
  createAudioGraph
    |> setNode "myOsc" createOscillatorNode
    |> addConnection (connect "myOsc" 0 "__destination" (InputChannel 0))
```
"""
    , button [ class "button", onClick Example_1 ] [ text "Run" ]
    , button [ class "button", onClick (Example_2 0) ] [ text "Stop" ]
    , Markdown.toHtml [ class "content" ] """
Now we're making some noise but we've just added a lot of
new stuff, what does it all do?

* First, we create a new audio graph as before.
* Then, we say we want to add a node to the graph and give
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

---

So now we have a (slightly annoying) tone coming out our speakers. Can we do anything
with that? How about we make a simple keyboard to play a C major scale?
"""
    , div [ class "is-horizontal-align" ]
        [ button [ class "button dark", onClick (Example_2 261.6) ] [ text "C" ]
        , button [ class "button dark", onClick (Example_2 293.7) ] [ text "D" ]
        , button [ class "button dark", onClick (Example_2 329.6) ] [ text "E" ]
        , button [ class "button dark", onClick (Example_2 349.2) ] [ text "F" ]
        , button [ class "button dark", onClick (Example_2 392.0) ] [ text "G" ]
        , button [ class "button dark", onClick (Example_2 440.0) ] [ text "A" ]
        , button [ class "button dark", onClick (Example_2 493.9) ] [ text "B" ]
        , button [ class "button dark", onClick (Example_2 523.3) ] [ text "C" ]
        , button [ class "button dark", onClick (Example_2 0) ] [ text "Stop" ]
        ]
    , Markdown.toHtml [ class "content" ] """
```elm
type alias model = AudioGraph

init = 
  createAudioGraph
    |> setNode "myOsc" createOscillatorNode
    |> addConnection (connect "myOsc" 0 "__destination" (InputChannel 0))

type Msg
  = UpdateFrequency Float
  | Stop

update msg model =
  case msg of
    UpdateFrequency freq ->
      createOscillatorNode
        |> updateParam "frequency" (Hertz freq)
        |> (\\n -> setNode "myOsc" n model)
        |> (\\m -> ( m, Cmd.none ))

    Stop ->
      createOscillatorNode
        |> updateParam "frequency" (Hertz 0)
        |> (\\n -> setNode "myOsc" n model)
        |> (\\m -> ( m, Cmd.none ))

view model = 
  div []
    [ button [ onClick (UpdateFrequency 261.6) ] [ text "C" ]
    , button [ onClick (UpdateFrequency 293.7) ] [ text "D" ]
    , ...
    , button [ onClick (UpdateFrequency 523.3) ] [ text "C" ]
    , button [ onClick Stop ] [ text "Stop" ]
    ]
```

"""
    ]
