#!/bin/bash
# Run the Elm test suite
# To execute the tests, elm-test requires that the directory of tests be called "tests"
mv elm-tests tests
elm-test
mv tests elm-tests
