#!/bin/bash
# Run all the test suites
cd tests
echo -e "\033[1;36mRunning Elm Tests\033[0m"
./elm-tests/run-elm-tests.sh
echo -e "\033[1;36mRunning Parser Tests\033[0m"
./parser-tests/run-parser-tests.sh
cd ..
