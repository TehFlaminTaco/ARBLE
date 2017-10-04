# ARBLE
A Rather Brief Lua Extension. A set of packaged libraries for golfing in lua.

## Running programs
Call ARBLE from the command line like so:

    lua ARBLE/short.lua <filename> [arguments, ...]

## Basic Info

### Extensions

Currently, ARBLE comes packaged with [equa.lua](http://github.com/tehflamintaco/equa.lua) implicitely imported.

### Implicit IO

If the executed program is a oneliner, its return value will be implicitely printed without a trailing newline to STDOUT.

If the first return value is a function or is callable, then it will be called with the command line arguments which are implicitely evaluated.
