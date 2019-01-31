export function createNode (context, opts) {
  switch (opts.type) {
    case "Analyser":
      return createAnalyser(context, opts)
    case "AudioBufferSource":
      return createAudioBufferSource(context, opts)
    case "AudioDestination":
      // No need to create a node in this case, just return the audio context
      // destination.
      return context.destination
    case "BiquadFilter":
      return createBiquadFilter(context, opts)
    case "ChannelMerger":
      return createChannelMerger(context, opts)
    case "ChannelSplitter":
      return createChannelSplitter(context, opts)
    case "ConstantSource":
      return createConstantSource(context, opts)
    case "Convolver":
      return createConvolver(context, opts)
    case "Delay":
      return createDelay(context, opts)
    case "DynamicsCompressor":
      return createDynamicsCompressor(context, opts)
    case "Gain":
      return createGain(context, opts)
    case "IIRFilter":
      return createIIRFilter(context, opts)
    case "Oscillator":
      return createOscillator(context, opts)
    case "Panner":
      return createPanner(context, opts)
    case "StereoPanner":
      return createStereoPanner(context, opts)
    case "WaveShaper":
      return createWaveshapper(context, opts)
  }
}

export function updateNode (node, { params, properties }) {
  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createAnalyser = (context, { type, params, properties }) => {
  let node = context.createAnalyser()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createAudioBufferSource = (context, { type, params, properties }) => {
  let node = context.createBufferSource()
      node.nodeType = type

  properties.map( prop => 
    prop.label !== 'buffer'
      ? prop
      : (context.createBuffer(1, prop.value.length, context.sampleRate))
          .getChannelData(0)
          .map((sample, i) => sample = prop.value[i]) )

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createBiquadFilter = (context, { type, params, properties }) => {
  let node = context.createBiquadFilter()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createChannelMerger = (context, { type, params, properties }) => {
  let node = context.createChannelMerger()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createChannelSplitter = (context, { type, params, properties }) => {
  let node = context.createChannelSplitter()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createConstantSource = (context, { type, params, properties }) => {
  let node = context.createConstantSource()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createConvolver = (context, { type, params, properties }) => {
  let node = context.createConvolver()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createDelay = (context, { type, params, properties }) => {
  let node = context.createDelay()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createDynamicsCompressor = (context, { type, params, properties }) => {
  let node = context.createDynamicsCompressor()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createGain = (context, { type, params, properties }) => {
  let node = context.createGain()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createIIRFilter = (context, { type, params, properties }) => {
  let node = context.createIIRFilter()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createOscillator = (context, { type, params, properties }) => {
  let node = context.createOscillator()
      node.nodeType = type
      node.start()

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createPanner = (context, { type, params, properties }) => {
  let node = context.createPanner()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createStereoPanner = (context, { type, params, properties }) => {
  let node = context.createStereoPanner()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}

const createWaveshapper = (context, { type, params, properties }) => {
  let node = context.createWaveshapper()
      node.nodeType = type

  params.forEach( param => node[param.label].value = param.value )
  properties.forEach( prop => node[prop.label] = prop.value )

  return node
}
