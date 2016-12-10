# FinalYearProject
The source code of my final year project; a tool for developing Web-based presentation slides from a simple markup language.

## Installation

1.  Get the code
2.  Run the following
```
elm-make src/editor.elm --output src/editor_elm.js
elm-make src/presenter.elm --output src/presenter_elm.js
cd src
npm install```

## Running

1.  Run the following
```
cd src
./node_modules/.bin/electron .```

## Testing

1.  Run the following
```
cd tests
./run-tests.sh```
2.  Smile at all that green
