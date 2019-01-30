import { Elm } from './Main.elm'
import createNode from './webAudioNodes'

const app = Elm.Main.init()

// A Web Audio context starts in a suspended state when it is created programmatically.
// This is to prevent potentially spammy applications from immediately playing
// sound. Here we just catch any click event on the body and resume/suspend the
// context accordingly.
document.querySelector('body')
  .addEventListener('click', () => {
    context.state !== "running"
      ? context.resume()
      : context.suspend()
  })

// We need to vendor prefix the AudioContext constructor.
const context = new (window.AudioContext || window.webkitAudioContext)
// Nodes contains the actual Web Audio Nodes.
const nodes = {}
// prevGraph is the last JSON graph we recieved from Elm, it starts null for
// obvious reasons.
const prevGraph = null

// Simple function to connect two nodes together. The connect function signature
// is slightly different dependent on whether you are connecting to a node or a
// param so a simple switch statement handles that logic.
function connectNodes ({ outputNode, outputChannel, inputNode, inputDestination }) {
  switch (inputDestination.type) {
    case "channel":
      nodes[outputNode].connect(nodes[inputNode], outputChannel, inputDestination.channel)
      break;
    case "param":
      nodes[outputNode].connect(nodes[inputNode][inputDestination.param], outputChannel)
      break;
  }
}

// Subscribe to the broadcastAudioPort to react to any changes in the audio graph.
// This is absolutely crucial if we want our graph to be reactively updated in real
// time.
app.ports.broadcastAudioGraph.subscribe(graph => {
  // At the moment the live audio graph only updates once, when the first graph
  // is receive from Elm.
  if (prevGraph === null) {
    // Iterate over the *keys* in graph.nodes. These are the IDs for each node
    // and we need to know that to add the nodes to our real graph.
    for (const id in graph.nodes)
      nodes[id] = createNode(context, graph.nodes[id])

    // Iterate over the *values* in graph.connections. 
    for (const connection of graph.connections)
      connectNodes(connection)
  }
})