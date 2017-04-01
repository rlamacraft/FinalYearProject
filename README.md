# FinalYearProject
The source code of my final year project; a tool for developing Web-based presentation slides from a simple markup language.

## Installation

1.  Get the code
2.  Run the following
```shell
elm-make src/editor/editor.elm --output src/editor/editor_elm.js
elm-make src/presenter/presenter.elm --output src/presenter/presenter_elm.js
cd src
npm install
cd presenter
pegjs -o parser.js parser.pegjs
```

## Running

1.  Run the following
```shell
cd src
./node_modules/.bin/electron .
```

## Testing

1.  Run the following
```shell
cd tests
./run-tests.sh
```

2.  Smile at all that green
