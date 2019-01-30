module AudioGraph.Units exposing
    ( Value(..)
    , DistanceModel(..), Filter(..), Oversample(..), PanningModel(..), Waveform(..)
    )

{-| The value of an [AudioParam](/AudioGraph#AudioParam) or [NodeProperty](/AudioGraph#NodeProperty)
is highly context relevant. Something that is expecting frequency in hertz may produce
very unexpected output if it receives a decibal value, even though they both represent
`Floats`. To encode this context the [Value](#Value) union type defines all the
possible contexts for primative types to exist in.

@docs Value


## Union Types

Some values, such as `WaveformType` are better expressed as their own union type,
rather than arbitrary string values.

@docs DistanceModel, Filter, Oversample, PanningModel, Waveform

-}


{-| -}
type Value
    = Attribute Bool
    | Buffer (List Float)
    | Coefficients (List Float)
    | Cents Float
    | Decibels Float
    | DistanceModelType DistanceModel
    | FilterType Filter
    | FFT_Size Int
    | Hertz Float
    | MIDI_Note Int
    | MIDI_CC Int
    | OversampleType Oversample
    | PanningModelType PanningModel
    | WaveformType Waveform
    | WaveshaperCurve (List Float)
      -- Primative wrappers
    | Number Float


{-| -}
type Filter
    = Lowpass
    | Highpass
    | Bandpass
    | Lowshelf
    | Highshelf
    | Peaking
    | Notch
    | Allpass


{-| -}
type Waveform
    = Sine
    | Triangle
    | Sawtooth
    | Square


{-| -}
type DistanceModel
    = Linear
    | Inverse
    | Exponential


{-| -}
type PanningModel
    = EqualPower
    | HRTF


{-| -}
type Oversample
    = None
    | TwoX
    | FourX
