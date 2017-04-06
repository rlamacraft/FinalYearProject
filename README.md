# FinalYearProject
The source code of my final year project; a tool for developing Web-based presentation slides from a simple markup language.

## Installation

1.  Get the code
2.  Run the following
```shell
cd src
elm-make editor/editor.elm --output editor/editor_elm.js
elm-make presenter/presenter.elm --output presenter/presenter_elm.js
npm install
cd editor/resources
mkdir css
sass sass/editor.sass > css/editor.css
cd ../../presenter
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
