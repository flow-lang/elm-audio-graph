import { Elm } from './Main.elm'
import { createNode, updateNode }from './webAudioNodes'

const app = Elm.Main.init()

// A Web Audio context starts in a suspended state when it is created programmatically.
// This is to prevent potentially spammy applications from immediately playing
// sound. Here we just catch any click event on the body and resume/suspend the
// context accordingly.
document.querySelector('body')
  .addEventListener('click', () => {
    if (context.state != "running")
      context.resume()
  })

// We need to vendor prefix the AudioContext constructor.
const context = new (window.AudioContext || window.webkitAudioContext)
// Nodes contains the actual Web Audio Nodes.
const nodes = {}
// prevGraph is the last JSON graph we recieved from Elm, it starts null for
// obvious reasons.
let prevGraph = null

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

function disconnectNodes ({ outputNode, outputChannel, inputNode, inputDestination }) {
  switch (inputDestination.type) {
    case "channel":
      nodes[outputNode].disconnect(nodes[inputNode], outputChannel, inputDestination.channel)
      break;
    case "param":
      nodes[outputNode].disconnect(nodes[inputNode][inputDestination.param], outputChannel)
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
  } else if (JSON.stringify(prevGraph) !== JSON.stringify(graph)) {
      // The following code is very naive. You don't want to do this in your own
      // applications!!!

      // Simply update the params and properties of an existing node
      // and create new nodes when necessary. This will not remove old
      // nodes and if a node's type changes nothing will happen.
      // T H I S  I S  B A D  C O D E .
      for (const id in graph.nodes) {
        if (nodes[id] === undefined)
          nodes[id] = createNode(context, graph.nodes[id])
        else if (nodes[id].nodeType === graph.nodes[id].type)
          nodes[id] = updateNode(nodes[id], graph.nodes[id])
      }

      for (const id in nodes) {
        if (graph.nodes[id] === undefined) {
          nodes[id].disconnect()
          delete nodes[id]
        }
      }

      for (const connection of graph.connections)
        connectNodes(connection)

      const disconnections = prevGraph.connections.filter(a => !graph.connections.some(b => JSON.stringify(a) === JSON.stringify(b)))

      for (const connection of disconnections)
        disconnectNodes(connection)
  }

  prevGraph = graph
})