# Deprecated
This package has been deprecated in favour of a new approach:
https://github.com/pd-andy/elm-web-audio

# elm-audio-graph

The elm-audio-graph package provides a type-safe way of constructing Web Audio processing graphs.
It is important to note that this package does not interface with the Web Audio API
directly, but provides methods to encode the created audio graph to JSON where
your javascript can handle the necessary creation and updating of Web Audio nodes.

### Who?

This package is for audio developers that would like to do sound processing on the
web but want to minimise their interaction with javascript directly. It seems unlikely
that the Elm language itself will support the Web Audio API any time soon, there
are more pressing Web APIs that need support for a far greater number of developers,
so this package aims to keep Elm developers inside the Elm ecosystem as much as
possible when developing audio applications on the web.

### Why?

[Here](https://gist.github.com/ohanhi/41ebfba2c26916dcc367680fb263c91f) is an excellent
list of reasons to use Elm in general. Many of these reasons translate to why you
would like to use Elm for your audio programming, but you already knew that if you're
here!

The biggest benefit to using this package is *type safety*. The type safety afforded
by a static programming like Elm is nice to have when doing front end development, but
is absolutely mission critical to have in audio programming. `Undefined is not a function`
or accidentally setting a variable to `null` may break the UI of your website, but
in real-time audio this will break **everything**. Audio dropouts and silent processing
graphs are sure fire ways of impressing nobody with your Web Audio app.