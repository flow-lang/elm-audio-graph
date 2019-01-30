module AudioGraph exposing
    ( AudioGraph(..)
    , setNode, getNode, removeNode, addConnection, removeConnection
    , AudioNode(..)
    , NodeID, NodeType(..), AudioParam(..), NodeProperty(..), NodeInput(..)
    , createAnalyserNode
    , createAudioBufferSourceNode
    , createAudioDestinationNode
    , createBiquadFilterNode
    , createChannelMergerNode
    , createChannelSplitterNode
    , createConstantSourceNode
    , createConvolverNode
    , createDelayNode
    , createDynamicsCompressorNode
    , createGainNode
    , createIIRFilterNode
    , createOscillatorNode
    , createPannerNode
    , createStereoPannerNode
    , createWaveShaperNode
    , updateParam, updateProperty
    , Connection, connect
    )

{-| The AudioGraph module provides methods to construct detailed, type safe, web
audio processing graphs in Elm. You can then use the [AudioGraph.Encode](/Encode)
module to serialise these graphs into JSON for proper reconstruction in javascript.


# Definition

@docs AudioGraph


## AudioGraph Manipulations

@docs setNode, getNode, removeNode, addConnection, removeConnection


# Audio Nodes

@docs AudioNode

@docs NodeID, NodeType, AudioParam, NodeProperty, NodeInput


## Audio Node Constructors

@docs createAnalyserNode
@docs createAudioBufferSourceNode
@docs createAudioDestinationNode
@docs createBiquadFilterNode
@docs createChannelMergerNode
@docs createChannelSplitterNode
@docs createConstantSourceNode
@docs createConvolverNode
@docs createDelayNode
@docs createDynamicsCompressorNode
@docs createGainNode
@docs createIIRFilterNode
@docs createOscillatorNode
@docs createPannerNode
@docs createStereoPannerNode
@docs createWaveShaperNode


## AudioNode Manipulations

@docs updateParam, updateProperty


## Connecting AudioNodes

@docs Connection, connect

-}

import AudioGraph.Units exposing (..)
import Dict exposing (Dict)


{-| The AudioGraph keeps track of all active audio nodes and their connections.
-}
type AudioGraph
    = AudioGraph
        { nodes : Dict NodeID AudioNode
        , connections : List Connection
        }


{-| Inserts a new [AudioNode](#AudioNode) into the graph with the supplied id string.
If a node already exists at the supplied id, the current node is replaced with the
new one.
-}
setNode : NodeID -> AudioNode -> AudioGraph -> AudioGraph
setNode id node graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.insert id node g.nodes }


{-| Queries the graph for the [AudioNode](#AudioNode) at the supplied id string.
Can return `Just AudioNode` or `Nothing` if no node exists at that id.
-}
getNode : NodeID -> AudioGraph -> Maybe AudioNode
getNode id graph =
    case graph of
        AudioGraph g ->
            Dict.get id g.nodes


{-| Removes the [AudioNode](#AudioNode) at the supplied id string from the graph.
This is a no-op if no node exists at that id.
-}
removeNode : NodeID -> AudioGraph -> AudioGraph
removeNode id graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.remove id g.nodes }


{-| Adds a new connection for the graph to track. There is a guard to prevent
duplicate connections being added.
-}
addConnection : Connection -> AudioGraph -> AudioGraph
addConnection connection graph =
    case graph of
        AudioGraph g ->
            if List.any (compareConnection connection) g.connections then
                graph

            else
                AudioGraph { g | connections = connection :: g.connections }


{-| Removes the supplied connection from the graph. If the connection doesn't exist
this is a no-op.
-}
removeConnection : Connection -> AudioGraph -> AudioGraph
removeConnection connection graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | connections = List.filter (\c -> not (compareConnection connection c)) g.connections }



-----------------------------
-- NODE CONNECTIONS
-----------------------------


{-| A Connection describes how one AudioNode connects to another. A connection can
exist in two forms: either a node can connect directly to another node's audio input,
or a node can connect to another node's params. The type of connection is detailed
by the inputDestination field.

See the [NodeInput](#NodeInput) definition for more information.

    -- Connect the output of "oscA" to the first input
    -- of "gain".
    connect "oscA" 0 "gain" (InputChannel 0)

    -- Connect the output of "oscB" to the frequency param
    -- of "oscA" to perform frequency modulation.
    connect "oscB" 0 "oscA" (InputParam "frequency")

-}
type alias Connection =
    { outputNode : NodeID
    , outputChannel : Int
    , inputNode : NodeID
    , inputDestination : NodeInput
    }


{-| A simple helper function to create a [Connection](#Connection). This is the
preferred way to construct Connections to avoid breaking API changes if the
Conncection type alias changes.
-}
connect : NodeID -> Int -> NodeID -> NodeInput -> Connection
connect outputNode outputChannel inputNode inputDestination =
    Connection outputNode outputChannel inputNode inputDestination


{-| An equality check of two connections. This is necessary for as the [NodeInput](#NodeInput)
union type is not comparable.
-}
compareConnection : Connection -> Connection -> Bool
compareConnection a b =
    a.outputNode
        == b.outputNode
        && a.outputChannel
        == b.outputChannel
        && a.inputNode
        == b.inputNode
        && compareNodeInput a.inputDestination b.inputDestination



-----------------------------
-- NODE TYPES
-----------------------------


{-| AudioNodes are the central focus of an [AudioGraph](#AudioGraph). They represent
any arbitrary audio processing node in a graph and can have any number of inputs,
outputs, parameters, and properties.

  - NodeType specifies the type of AudioNode. Each type is a 1:1 name
    mapping of its Web Audio counterpart, so you can always refer to the Web Audio
    documentation for more details.
  - Params is a list of audio-rate parameters that the AudioNode exposes. These can
    be modulated by other AudioNodes. See [AudioParam](#AudioParam) for more information.
  - Properties lists an **non**-audio-rate properties of the AudioNode. These include
    properties like oscillator waveform type or filter type. Typically these are set
    once when the node is created. Other AudioNodes _cannot_ connect to a NodeProperty.
  - Inputs is a list of all the points another AudioNode can connect to this node. These
    can either be `InputChannel`s that are numbered from 0, or `InputParam`s that expose
    the node's params for connection. See [NodeInput](#NodeInput) for more details.
  - NumOutputs is an integer stating the number of audio outputs the node has. **Note**:
    the Web Audio API treats input/output count and channel count seperately. A node may
    only have one output but may still be stereo.

-}
type AudioNode
    = AudioNode
        { nodeType : NodeType
        , params : List AudioParam
        , properties : List NodeProperty
        , inputs : List NodeInput
        , numOutputs : Int
        }


{-| Describes what type of node an AudioNode represents. These are 1:1 mappings
of the audio nodes detailed in the Web Audio API so refer [here](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)
for more information on each node.
-}
type NodeType
    = AnalyserNode
    | AudioBufferSourceNode
    | AudioDestinationNode
    | BiquadFilterNode
    | ChannelMergerNode
    | ChannelSplitterNode
    | ConstantSourceNode
    | ConvolverNode
    | DelayNode
    | DynamicsCompressorNode
    | GainNode
    | IIRFilterNode
    | OscillatorNode
    | PannerNode
    | StereoPannerNode
    | WaveShaperNode


{-| A simple type alias for more expressive type annotations. NodeIDs are used
as keys in the AudioGraph nodes dictionary.
-}
type alias NodeID =
    String


{-| The AudioParam type represents a Web Audio [audio param](https://developer.mozilla.org/en-US/docs/Web/API/AudioParam).
The follow description is abridged from the Web Audio API docs:

> The Web Audio API's AudioParam interface represents an audio-related parameter,
> usually a parameter of an AudioNode (such as GainNode.gain)
>
> There are two kinds of AudioParam, a-rate and k-rate parameters:
>
>   - An a-rate AudioParam takes the current audio parameter value for each sample frame of the audio signal.
>   - A k-rate AudioParam uses the same initial audio parameter value for the whole block processed, that is 128 sample frames.

The distinction between a-rate and k-rate is useful to know when processing audio,
but does not impact how params are used. All `AudioParam`s can be modulated by
`AudioNode`s.

-}
type AudioParam
    = AudioParam
        { label : String
        , value : Value
        }


{-| A NodeProperty is used in much the same way as an [AudioParam](#AudioParam).
The key distinction is that NodeProperties **cannot** be modulated by other `AudioNodes`.

While their values can be updated programmatically, they cannot be continuously
modulated by an audio signal.

-}
type NodeProperty
    = NodeProperty
        { label : String
        , value : Value
        }


{-| Every [AudioNode](#AudioNode) can have some number of inputs, and these inputs
can correspond to a direct audio input channel on the node, or an [AudioParam](#AudioParam).

  - InputChannel represents the channel number of an audio input for the node. These
    are zero-indexed.
  - InputParam represents the `label` of the parameter to connect to.

-}
type NodeInput
    = InputChannel Int
    | InputParam String


compareNodeInput : NodeInput -> NodeInput -> Bool
compareNodeInput a b =
    case ( a, b ) of
        ( InputChannel _, InputParam _ ) ->
            False

        ( InputParam _, InputChannel _ ) ->
            False

        ( InputChannel aChannel, InputChannel bChannel ) ->
            aChannel == bChannel

        ( InputParam aParam, InputParam bParam ) ->
            aParam == bParam



-----------------------------
-- NODE CONSTRUCTORS
-----------------------------


{-| Creates an [AnalyserNode](https://developer.mozilla.org/en-US/docs/Web/API/AnalyserNode).

    AudioNode
        { nodeType = AnalyserNode
        , params = []
        , properties =
            [ NodeProperty { label = "fftSize", value = FFT_Size 2048 }
            , NodeProperty { label = "minDecibels", value = Decibels -100 }
            , NodeProperty { label = "maxDecibels", value = Decibels -30 }
            , NodeProperty { label = "smoothingTimeConstant", value = Number 0.8 }
            ]
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 1
        }

-}
createAnalyserNode : AudioNode
createAnalyserNode =
    AudioNode
        { nodeType = AnalyserNode
        , params = []
        , properties =
            [ NodeProperty { label = "fftSize", value = FFT_Size 2048 }
            , NodeProperty { label = "minDecibels", value = Decibels -100 }
            , NodeProperty { label = "maxDecibels", value = Decibels -30 }
            , NodeProperty { label = "smoothingTimeConstant", value = Number 0.8 }
            ]
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 1
        }


{-| Creates an [AudioBufferSourceNode](https://developer.mozilla.org/en-US/docs/Web/API/AudioBufferSourceNode).

    AudioNode
        { nodeType = AudioBufferSourceNode
        , params =
            [ AudioParam { label = "detune", value = Cents 0 }
            , AudioParam { label = "playbackRate", value = Number 1.0 }
            ]
        , properties =
            [ NodeProperty { label = "buffer", value = Buffer [] }
            , NodeProperty { label = "loop", value = Attribute False }
            , NodeProperty { label = "loopStart", value = Number 0 }
            , NodeProperty { label = "loopEnd", value = Number 0 }
            ]
        , inputs =
            [ InputParam "detune"
            , InputParam "playerbackRate"
            ]
        , numOutputs = 1
        }

-}
createAudioBufferSourceNode : AudioNode
createAudioBufferSourceNode =
    AudioNode
        { nodeType = AudioBufferSourceNode
        , params =
            [ AudioParam { label = "detune", value = Cents 0 }
            , AudioParam { label = "playbackRate", value = Number 1.0 }
            ]
        , properties =
            [ NodeProperty { label = "buffer", value = Buffer [] }
            , NodeProperty { label = "loop", value = Attribute False }
            , NodeProperty { label = "loopStart", value = Number 0 }
            , NodeProperty { label = "loopEnd", value = Number 0 }
            ]
        , inputs =
            [ InputParam "detune"
            , InputParam "playerbackRate"
            ]
        , numOutputs = 1
        }


{-| Creates an [AudioDestinationNode](https://developer.mozilla.org/en-US/docs/Web/API/AudioDestinationNode).

    AudioNode
        { nodeType = AudioDestinationNode
        , params = []
        , properties = []
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 0
        }

-}
createAudioDestinationNode : AudioNode
createAudioDestinationNode =
    AudioNode
        { nodeType = AudioDestinationNode
        , params = []
        , properties = []
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 0
        }


{-| Creates a [BiquadFilterNode](https://developer.mozilla.org/en-US/docs/Web/API/BiquadFilterNode).

    AudioNode
        { nodeType = BiquadFilterNode
        , params =
            [ AudioParam { label = "frequency", value = Hertz 350 }
            , AudioParam { label = "detune", value = Cents 0 }
            , AudioParam { label = "Q", value = Number 1.0 }
            ]
        , properties =
            [ NodeProperty { label = "type", value = FilterType Lowpass }
            ]
        , inputs =
            [ InputParam "frequency"
            , InputParam "detune"
            , InputParam "Q"
            ]
        , numOutputs = 1
        }

-}
createBiquadFilterNode : AudioNode
createBiquadFilterNode =
    AudioNode
        { nodeType = BiquadFilterNode
        , params =
            [ AudioParam { label = "frequency", value = Hertz 350 }
            , AudioParam { label = "detune", value = Cents 0 }
            , AudioParam { label = "Q", value = Number 1.0 }
            ]
        , properties =
            [ NodeProperty { label = "type", value = FilterType Lowpass }
            ]
        , inputs =
            [ InputParam "frequency"
            , InputParam "detune"
            , InputParam "Q"
            ]
        , numOutputs = 1
        }


{-| Creates a [ChannelMergerNode](https://developer.mozilla.org/en-US/docs/Web/API/ChannelMergerNode).

    AudioNode
        { nodeType = ChannelMergerNode
        , params = []
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputChannel 1
            , InputChannel 2
            , InputChannel 3
            , InputChannel 4
            , InputChannel 5
            ]
        , numOutputs = 1
        }

-}
createChannelMergerNode : AudioNode
createChannelMergerNode =
    AudioNode
        { nodeType = ChannelMergerNode
        , params = []
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputChannel 1
            , InputChannel 2
            , InputChannel 3
            , InputChannel 4
            , InputChannel 5
            ]
        , numOutputs = 1
        }


{-| Creates a [ChannelSplitterNode](https://developer.mozilla.org/en-US/docs/Web/API/ChannelSplitterNode).

    AudioNode
        { nodeType = ChannelSplitterNode
        , params = []
        , properties = []
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 6
        }

-}
createChannelSplitterNode : AudioNode
createChannelSplitterNode =
    AudioNode
        { nodeType = ChannelSplitterNode
        , params = []
        , properties = []
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 6
        }


{-| Creates a [ConstantSourceNode](https://developer.mozilla.org/en-US/docs/Web/API/ConstantSourceNode).

    AudioNode
        { nodeType = ConstantSourceNode
        , params =
            [ AudioParam { label = "offset", value = Number 1.0 }
            ]
        , properties = []
        , inputs =
            [ InputParam "offset"
            ]
        , numOutputs = 1
        }

-}
createConstantSourceNode : AudioNode
createConstantSourceNode =
    AudioNode
        { nodeType = ConstantSourceNode
        , params =
            [ AudioParam { label = "offset", value = Number 1.0 }
            ]
        , properties = []
        , inputs =
            [ InputParam "offset"
            ]
        , numOutputs = 1
        }


{-| Creates a [ConvolverNode](https://developer.mozilla.org/en-US/docs/Web/API/ConvolverNode).

    AudioNode
        { nodeType = ConvolverNode
        , params = []
        , properties =
            [ NodeProperty { label = "buffer", value = Buffer [] }
            , NodeProperty { label = "normalize", value = Attribute False }
            ]
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 1
        }

-}
createConvolverNode : AudioNode
createConvolverNode =
    AudioNode
        { nodeType = ConvolverNode
        , params = []
        , properties =
            [ NodeProperty { label = "buffer", value = Buffer [] }
            , NodeProperty { label = "normalize", value = Attribute False }
            ]
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 1
        }


{-| Creates a [DelayNode](https://developer.mozilla.org/en-US/docs/Web/API/DelayNode).

    AudioNode
        { nodeType = DelayNode
        , params =
            [ AudioParam { label = "delayTime", value = Number 0 }
            ]
        , properties =
            [ NodeProperty { label = "maxDelayTime", value = Number 1.0 }
            ]
        , inputs =
            [ InputChannel 0
            , InputParam "delayTime"
            ]
        , numOutputs = 1
        }

-}
createDelayNode : AudioNode
createDelayNode =
    AudioNode
        { nodeType = DelayNode
        , params =
            [ AudioParam { label = "delayTime", value = Number 0 }
            ]
        , properties =
            [ NodeProperty { label = "maxDelayTime", value = Number 1.0 }
            ]
        , inputs =
            [ InputChannel 0
            , InputParam "delayTime"
            ]
        , numOutputs = 1
        }


{-| Creates a [DynamicsCompressorNode](https://developer.mozilla.org/en-US/docs/Web/API/DynamicsCompressorNode).

    AudioNode
        { nodeType = DynamicsCompressorNode
        , params =
            [ AudioParam { label = "threshold", value = Decibels -24 }
            , AudioParam { label = "knee", value = Decibels 30 }
            , AudioParam { label = "ratio", value = Number 12 }
            , AudioParam { label = "attack", value = Number 0.003 }
            , AudioParam { label = "release", value = Number 0.25 }
            ]
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputParam "threshold"
            , InputParam "knee"
            , InputParam "ratio"
            , InputParam "attack"
            , InputParam "release"
            ]
        , numOutputs = 1
        }

-}
createDynamicsCompressorNode : AudioNode
createDynamicsCompressorNode =
    AudioNode
        { nodeType = DynamicsCompressorNode
        , params =
            [ AudioParam { label = "threshold", value = Decibels -24 }
            , AudioParam { label = "knee", value = Decibels 30 }
            , AudioParam { label = "ratio", value = Number 12 }
            , AudioParam { label = "attack", value = Number 0.003 }
            , AudioParam { label = "release", value = Number 0.25 }
            ]
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputParam "threshold"
            , InputParam "knee"
            , InputParam "ratio"
            , InputParam "attack"
            , InputParam "release"
            ]
        , numOutputs = 1
        }


{-| Creates a [GainNode](https://developer.mozilla.org/en-US/docs/Web/API/GainNode).

    AudioNode
        { nodeType = GainNode
        , params =
            [ AudioParam { label = "gain", value = Number 1.0 }
            ]
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputParam "gain"
            ]
        , numOutputs = 1
        }

-}
createGainNode : AudioNode
createGainNode =
    AudioNode
        { nodeType = GainNode
        , params =
            [ AudioParam { label = "gain", value = Number 1.0 }
            ]
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputParam "gain"
            ]
        , numOutputs = 1
        }


{-| Creates an [IIRFilterNode](https://developer.mozilla.org/en-US/docs/Web/API/IIRFilterNode).

    AudioNode
        { nodeType = IIRFilterNode
        , params =
            [ AudioParam { label = "feedforward", value = Coefficients [] }
            , AudioParam { label = "feedbackward", value = Coefficients [] }
            ]
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputParam "feedforward"
            , InputParam "feedbackward"
            ]
        , numOutputs = 1
        }

-}
createIIRFilterNode : AudioNode
createIIRFilterNode =
    AudioNode
        { nodeType = IIRFilterNode
        , params =
            [ AudioParam { label = "feedforward", value = Coefficients [] }
            , AudioParam { label = "feedbackward", value = Coefficients [] }
            ]
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputParam "feedforward"
            , InputParam "feedbackward"
            ]
        , numOutputs = 1
        }


{-| Creates an [OscillatorNode](https://developer.mozilla.org/en-US/docs/Web/API/OscillatorNode).

    AudioNode
        { nodeType = OscillatorNode
        , params =
            [ AudioParam { label = "frequency", value = Hertz 350 }
            , AudioParam { label = "detune", value = Cents 0 }
            ]
        , properties =
            [ NodeProperty { label = "type", value = WaveformType Sine }
            ]
        , inputs =
            [ InputParam "frequency"
            , InputParam "detune"
            ]
        , numOutputs = 1
        }

-}
createOscillatorNode : AudioNode
createOscillatorNode =
    AudioNode
        { nodeType = OscillatorNode
        , params =
            [ AudioParam { label = "frequency", value = Hertz 350 }
            , AudioParam { label = "detune", value = Cents 0 }
            ]
        , properties =
            [ NodeProperty { label = "type", value = WaveformType Sine }
            ]
        , inputs =
            [ InputParam "frequency"
            , InputParam "detune"
            ]
        , numOutputs = 1
        }


{-| Creates a [PannerNode](https://developer.mozilla.org/en-US/docs/Web/API/PannerNode).

    AudioNode
        { nodeType = PannerNode
        , params =
            [ AudioParam { label = "orientationX", value = Number 1 }
            , AudioParam { label = "orientationY", value = Number 0 }
            , AudioParam { label = "orientationZ", value = Number 0 }
            , AudioParam { label = "positionX", value = Number 0 }
            , AudioParam { label = "positionY", value = Number 0 }
            , AudioParam { label = "positionZ", value = Number 0 }
            ]
        , properties =
            [ NodeProperty { label = "coneInnerAngle", value = Number 360 }
            , NodeProperty { label = "coneOuterAngle", value = Number 0 }
            , NodeProperty { label = "coneOuterGain", value = Number 0 }
            , NodeProperty { label = "distanceModel", value = DistanceModelType Inverse }
            , NodeProperty { label = "maxDistance", value = Number 10000 }
            , NodeProperty { label = "panningModel", value = PanningModelType EqualPower }
            , NodeProperty { label = "refDistance", value = Number 1 }
            , NodeProperty { label = "rolloffFactor", value = Number 1 }
            ]
        , inputs =
            [ InputChannel 0
            , InputParam "orientationX"
            , InputParam "orientationY"
            , InputParam "orientationZ"
            , InputParam "positionX"
            , InputParam "positionY"
            , InputParam "positionZ"
            ]
        , numOutputs = 1
        }

-}
createPannerNode : AudioNode
createPannerNode =
    AudioNode
        { nodeType = PannerNode
        , params =
            [ AudioParam { label = "orientationX", value = Number 1 }
            , AudioParam { label = "orientationY", value = Number 0 }
            , AudioParam { label = "orientationZ", value = Number 0 }
            , AudioParam { label = "positionX", value = Number 0 }
            , AudioParam { label = "positionY", value = Number 0 }
            , AudioParam { label = "positionZ", value = Number 0 }
            ]
        , properties =
            [ NodeProperty { label = "coneInnerAngle", value = Number 360 }
            , NodeProperty { label = "coneOuterAngle", value = Number 0 }
            , NodeProperty { label = "coneOuterGain", value = Number 0 }
            , NodeProperty { label = "distanceModel", value = DistanceModelType Inverse }
            , NodeProperty { label = "maxDistance", value = Number 10000 }
            , NodeProperty { label = "panningModel", value = PanningModelType EqualPower }
            , NodeProperty { label = "refDistance", value = Number 1 }
            , NodeProperty { label = "rolloffFactor", value = Number 1 }
            ]
        , inputs =
            [ InputChannel 0
            , InputParam "orientationX"
            , InputParam "orientationY"
            , InputParam "orientationZ"
            , InputParam "positionX"
            , InputParam "positionY"
            , InputParam "positionZ"
            ]
        , numOutputs = 1
        }


{-| Creates a [StereoPannerNode](https://developer.mozilla.org/en-US/docs/Web/API/StereoPannerNode).

    AudioNode
        { nodeType = StereoPannerNode
        , params =
            [ AudioParam { label = "pan", value = Number 0 }
            ]
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputParam "pan"
            ]
        , numOutputs = 1
        }

-}
createStereoPannerNode : AudioNode
createStereoPannerNode =
    AudioNode
        { nodeType = StereoPannerNode
        , params =
            [ AudioParam { label = "pan", value = Number 0 }
            ]
        , properties = []
        , inputs =
            [ InputChannel 0
            , InputParam "pan"
            ]
        , numOutputs = 1
        }


{-| Creates a [WaveShaperNode](https://developer.mozilla.org/en-US/docs/Web/API/WaveShaperNode).

    AudioNode
        { nodeType = WaveShaperNode
        , params = []
        , properties =
            [ NodeProperty { label = "curve", value = WaveshaperCurve [] }
            , NodeProperty { label = "oversample", value = OversampleType None }
            ]
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 1
        }

-}
createWaveShaperNode : AudioNode
createWaveShaperNode =
    AudioNode
        { nodeType = WaveShaperNode
        , params = []
        , properties =
            [ NodeProperty { label = "curve", value = WaveshaperCurve [] }
            , NodeProperty { label = "oversample", value = OversampleType None }
            ]
        , inputs =
            [ InputChannel 0
            ]
        , numOutputs = 1
        }



-----------------------------
-- NODE UPDATERS
-----------------------------


{-| Update the [Value](AudioGraph.Units#Value) stored in an [AudioParam](#AudioParam).

Note: If an [AudioNode](#AudioNode) is connected to this param, `updateParam` will
have no effect.

-}
updateParam : String -> Value -> AudioNode -> AudioNode
updateParam label value node =
    let
        updateValue param =
            case param of
                AudioParam p ->
                    if p.label == label then
                        AudioParam { label = label, value = value }

                    else
                        param
    in
    case node of
        AudioNode n ->
            AudioNode { n | params = List.map updateValue n.params }


{-| Update the [Value](/AudioGraph.Units#Value) stored in a [NodeProperty](#NodeProperty).
-}
updateProperty : String -> Value -> AudioNode -> AudioNode
updateProperty label value node =
    let
        updateValue property =
            case property of
                NodeProperty p ->
                    if p.label == label then
                        NodeProperty { label = label, value = value }

                    else
                        property
    in
    case node of
        AudioNode n ->
            AudioNode { n | properties = List.map updateValue n.properties }
