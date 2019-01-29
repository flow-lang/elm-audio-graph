module AudioGraph.Units exposing (DistanceModel(..), Filter(..), Oversample(..), PanningModel(..), Value(..), Waveform(..))

{-| -}


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
