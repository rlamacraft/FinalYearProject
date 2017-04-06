module ParsingHandlingTests exposing (all)

import ParsingHandling as PH
import Statement exposing (Statement)
import Test exposing (..)
import Expect

all : Test
all =
  describe "All Parsing Handling Tests"
    [ processStatement
    , buildStatementTree
    ]

processStatement : Test
processStatement =
  let
    simpleStringStatement = Statement.StringStatement "foo"
    childCommand          = Statement.Command "childCommand" [] ""
  in
    describe "Tests for processStatement"
      [ test "Simple String" <|
        \() ->
          PH.processStatement "_string" [] "foo"
            |> Expect.equal simpleStringStatement
      , test "Empty String" <|
        \() ->
          PH.processStatement "_string" [] ""
            |> Expect.equal (Statement.StringStatement "")
      , test "Simple Component" <|
        \() ->
          PH.processStatement "componentName" [ simpleStringStatement ] "foo"
            |> Expect.equal (Statement.Command "componentName" [ simpleStringStatement ] "foo")
      , test "Empty Component" <|
        \() ->
          PH.processStatement "componentName" [] ""
            |> Expect.equal (Statement.Command "componentName" [] "")
      , test "Nested Components" <|
        \() ->
          PH.processStatement "parentComponent" [ childCommand ] ""
            |> Expect.equal (Statement.Command "parentComponent" [ childCommand ] "")
      ]

buildStatementTree : Test
buildStatementTree =
  let
    simpleStringStatement = Statement.StringStatement "foo\n"
    simpleCommand = Statement.Command "a" [ Statement.StringStatement "b" ] "b"
  in
    describe "Tests for buildStatementTree"
      [ test "Empty String" <|
        \() ->
          PH.buildStatementTree ""
            |> Expect.equal (Err "Could not decode JSON string from parser: Given an invalid JSON: Unexpected end of input")
      , test "Empty Array" <|
        \() ->
          PH.buildStatementTree "[]"
            |> Expect.equal (Ok [])
      , test "Simple String" <|
        \() ->
          PH.buildStatementTree """[{"name":"_string","content":[],"rawContent":"foo\\n"}]"""
            |> Expect.equal (Ok [ simpleStringStatement ] )
      , test "Simple Command" <|
        \() ->
          PH.buildStatementTree """[{"name":"a","content":[{"name":"_string","content":[],"rawContent":"b"}],"rawContent":"b"}]"""
            |> Expect.equal (Ok [ simpleCommand ] )
      , test "Command without Name" <|
        \() ->
          PH.buildStatementTree """[{"content":[{"name":"_string","content":[],"rawContent":"b"}],"rawContent":"b"}]"""
            |> Expect.equal (Err "Could not decode JSON string from parser: Expecting an object with a field named `name` at _[0] but instead got: {\"content\":[{\"name\":\"_string\",\"content\":[],\"rawContent\":\"b\"}],\"rawContent\":\"b\"}" )
      , test "Command without content" <|
        \() ->
          PH.buildStatementTree """[{"name":"a","rawContent":"b"}]"""
            |> Expect.equal (Err "Could not decode JSON string from parser: Expecting an object with a field named `content` at _[0] but instead got: {\"name\":\"a\",\"rawContent\":\"b\"}" )
      , test "Command without raw content" <|
        \() ->
          PH.buildStatementTree """[{"name":"a","content":[{"name":"_string","content":[],"rawContent":"b"}]}]"""
            |> Expect.equal (Err "Could not decode JSON string from parser: Expecting an object with a field named `rawContent` at _[0] but instead got: {\"name\":\"a\",\"content\":[{\"name\":\"_string\",\"content\":[],\"rawContent\":\"b\"}]}" )
      ]
