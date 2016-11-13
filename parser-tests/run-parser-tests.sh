#!/bin/bash
# Run the Parser test suite
# To execute the tests, mocha requires that the directory of tests be called "test"
mv parser-tests test
./node_modules/mocha/bin/mocha
mv test parser-tests
