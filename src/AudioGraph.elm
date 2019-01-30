module AudioGraph exposing 
    ( AudioGraph(..), setNode, getNode, removeNode, addConnection, removeConnection
    , Connection, connect
    , AudioNode(..), updateParam, updateProperty
    , AudioParam(..)
    , NodeID
    , NodeInput(..)
    , NodeProperty(..)
    , NodeType(..)
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
    )

{-| -}

import AudioGraph.Units exposing (..)
import Dict exposing (Dict)


{-| -}
type AudioGraph
    = AudioGraph
        { nodes : Dict NodeID AudioNode
        , connections : List Connection
        }


{-| -}
setNode : NodeID -> AudioNode -> AudioGraph -> AudioGraph
setNode id node graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.insert id node g.nodes }


{-| -}
getNode : NodeID -> AudioGraph -> AudioGraph
getNode id graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.remove id g.nodes }


{-| -}
removeNode : NodeID -> AudioGraph -> AudioGraph
removeNode id graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.remove id g.nodes }


{-| -}
addConnection : Connection -> AudioGraph -> AudioGraph
addConnection connection graph =
    case graph of
        AudioGraph g ->
            if List.any (compareConnection connection) g.connections then
              graph

            else
                AudioGraph { g | connections = connection :: g.connections }


removeConnection : Connection -> AudioGraph -> AudioGraph
removeConnection connection graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | connections = List.filter (\c -> not (compareConnection connection c)) g.connections }       


-----------------------------
-- NODE CONNECTIONS
-----------------------------


{-| -}
type alias Connection =
    { outputNode : NodeID
    , outputChannel : Int
    , inputNode : NodeID
    , inputDestination : NodeInput
    }


{-| -}
connect : NodeID -> Int -> NodeID -> NodeInput -> Connection
connect outputNode outputChannel inputNode inputDestination =
    Connection outputNode outputChannel inputNode inputDestination


compareConnection : Connection -> Connection -> Bool
compareConnection a b =
      a.outputNode == b.outputNode
      && a.outputChannel == b.outputChannel
      && a.inputNode == b.inputNode
      && compareNodeInput a.inputDestination b.inputDestination


-----------------------------
-- NODE TYPES
-----------------------------


{-| -}
type AudioNode
    = AudioNode
        { nodeType : NodeType
        , params : List AudioParam
        , properties : List NodeProperty
        , inputs : List NodeInput
        , numOutputs : Int
        }


{-| -}
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


{-| -}
type alias NodeID = String


{-| -}
type AudioParam
    = AudioParam
        { label : String
        , value : Value
        }


{-| -}
type NodeProperty
    = NodeProperty
        { label : String
        , value : Value
        }


{-| -}
type NodeInput
    = InputChannel Int
    | InputParam String


compareNodeInput : NodeInput -> NodeInput -> Bool
compareNodeInput a b =
    case (a, b) of
        (InputChannel _, InputParam _) ->
            False

        (InputParam _, InputChannel _) ->
            False

        (InputChannel aChannel, InputChannel bChannel) ->
            aChannel == bChannel

        (InputParam aParam, InputParam bParam) ->
            aParam == bParam


-----------------------------
-- NODE CONSTRUCTORS
-----------------------------


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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


{-| -}
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
