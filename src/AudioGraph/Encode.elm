module AudioGraph.Encode exposing
    ( encodeGraph
    , encodeNode
    )

{-| -}

import AudioGraph exposing (..)
import AudioGraph.Units exposing (..)
import Dict exposing (Dict)
import Json.Encode as E exposing (encode)


{-| -}
encodeGraph : AudioGraph -> E.Value
encodeGraph graph =
    case graph of
        AudioGraph g ->
            E.object
                [ ( "nodes", E.dict identity encodeNode g.nodes )
                , ( "connections", E.list encodeConnection g.connections )
                ]



-----------------------------
-- AUDIO_NODE ENCODER
-----------------------------


{-| -}
encodeNode : AudioNode -> E.Value
encodeNode node =
    case node of
        AudioNode n ->
            E.object
                [ ( "type", encodeNodeType n.nodeType )
                , ( "params", E.list encodeAudioParam n.params )
                , ( "properties", E.list encodeNodeProperty n.properties )
                , ( "inputs", E.list encodeNodeInput n.inputs )
                , ( "numOutputs", E.int n.numOutputs )
                ]


encodeNodeType : NodeType -> E.Value
encodeNodeType nodeType =
    case nodeType of
        AnalyserNode ->
            E.string "Analyser"

        AudioBufferSourceNode ->
            E.string "AudioBufferSource"

        AudioDestinationNode ->
            E.string "AudioDestination"

        BiquadFilterNode ->
            E.string "BiquadFilter"

        ChannelMergerNode ->
            E.string "ChannelMerger"

        ChannelSplitterNode ->
            E.string "ChannelSplitter"

        ConstantSourceNode ->
            E.string "ConstantSource"

        ConvolverNode ->
            E.string "Convolver"

        DelayNode ->
            E.string "Delay"

        DynamicsCompressorNode ->
            E.string "DynamicsCompressor"

        GainNode ->
            E.string "Gain"

        IIRFilterNode ->
            E.string "IIRFilter"

        OscillatorNode ->
            E.string "Oscillator"

        PannerNode ->
            E.string "Panner"

        StereoPannerNode ->
            E.string "StereoPanner"

        WaveShaperNode ->
            E.string "WaveShaper"


encodeAudioParam : AudioParam -> E.Value
encodeAudioParam param =
    case param of
        AudioParam p ->
            E.object
                [ ( "label", E.string p.label )
                , ( "value", encodeValue p.value )
                ]


encodeNodeProperty : NodeProperty -> E.Value
encodeNodeProperty property =
    case property of
        NodeProperty p ->
            E.object
                [ ( "label", E.string p.label )
                , ( "value", encodeValue p.value )
                ]


encodeNodeInput : NodeInput -> E.Value
encodeNodeInput input =
    case input of
        InputChannel c ->
            E.object
                [ ( "type", E.string "channel" )
                , ( "channel", E.int c )
                ]

        InputParam p ->
            E.object
                [ ( "type", E.string "param" )
                , ( "param", E.string p )
                ]



-----------------------------
-- CONNECTION ENCODER
-----------------------------


encodeConnection : Connection -> E.Value
encodeConnection connection =
    E.object
        [ ( "outputNode", E.string connection.outputNode )
        , ( "outputChannel", E.int connection.outputChannel )
        , ( "inputNode", E.string connection.inputNode )
        , ( "inputDestination", encodeNodeInput connection.inputDestination )
        ]



-----------------------------
-- UNIT ENCODER
-----------------------------


encodeValue : Value -> E.Value
encodeValue value =
    case value of
        Attribute attr ->
            E.bool attr

        Buffer buff ->
            E.list E.float buff

        Coefficients coef ->
            E.list E.float coef

        Cents c ->
            E.float c

        Decibels db ->
            E.float db

        DistanceModelType model ->
            encodeDistanceModelType model

        FilterType f ->
            encodeFilterType f

        FFT_Size size ->
            E.int size

        Hertz hz ->
            E.float hz

        MIDI_Note note ->
            E.int note

        MIDI_CC cc ->
            E.int cc

        OversampleType oversample ->
            encodeOversampleType oversample

        PanningModelType model ->
            encodePanningModelType model

        WaveformType wave ->
            encodeWaveformType wave

        WaveshaperCurve curve ->
            E.list E.float curve

        Number n ->
            E.float n


encodeFilterType : Filter -> E.Value
encodeFilterType f =
    case f of
        Lowpass ->
            E.string "lowpass"

        Highpass ->
            E.string "highpass"

        Bandpass ->
            E.string "bandpass"

        Lowshelf ->
            E.string "lowshelf"

        Highshelf ->
            E.string "highshelf"

        Peaking ->
            E.string "peaking"

        Notch ->
            E.string "notch"

        Allpass ->
            E.string "allpass"


encodeWaveformType : Waveform -> E.Value
encodeWaveformType wave =
    case wave of
        Sine ->
            E.string "sine"

        Triangle ->
            E.string "triangle"

        Sawtooth ->
            E.string "sawtooth"

        Square ->
            E.string "square"


encodeDistanceModelType : DistanceModel -> E.Value
encodeDistanceModelType model =
    case model of
        Linear ->
            E.string "linear"

        Inverse ->
            E.string "inverse"

        Exponential ->
            E.string "exponential"


encodePanningModelType : PanningModel -> E.Value
encodePanningModelType model =
    case model of
        EqualPower ->
            E.string "equalpower"

        HRTF ->
            E.string "HRTF"


encodeOversampleType : Oversample -> E.Value
encodeOversampleType oversample =
    case oversample of
        None ->
            E.string "none"

        TwoX ->
            E.string "2x"

        FourX ->
            E.string "4x"
