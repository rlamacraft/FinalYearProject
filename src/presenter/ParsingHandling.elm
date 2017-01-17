module ParsingHandling exposing (..)
{-
  Convert the parsed input text as a JSON string into the described data model
-}

import Json.Decode exposing (..)
import Json.Decode.Extra exposing (..)

type Statement = Command String (List Statement) String | StringStatement String

-- Decode a nested JSON string of 'Statements' as objects into the above Statement type
statementDecoder : Decoder Statement
statementDecoder =
  object3
    processStatement
    ("name" := string)
    ("content" := list (lazy (\_ -> statementDecoder)))
    ("rawContent" := string)

-- Convert a decoded 'Statement' JSON String into a 'Statement' Union Type
processStatement : String -> (List Statement) -> String -> Statement
processStatement name content rawContent =
  case name of
    "_string" ->
      StringStatement rawContent
    _ ->
      Command name content rawContent

-- Convert a JSON string of 'Statement's into a list of Statements
buildStatementTree : String -> Result String (List Statement)
buildStatementTree parsedStatementsJson =
  case decodeString (list statementDecoder) parsedStatementsJson of
    Err msg ->
      Err <| "Could not decode JSON string from parser: " ++ msg
    Ok decodedStatements ->
      Ok decodedStatements
