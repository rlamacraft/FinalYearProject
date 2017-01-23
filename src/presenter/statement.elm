module Statement exposing (Statement(..), numOfLeafCommandDescendents, isRenderable)

import List exposing (sum,map,all)

type Statement = Command String (List Statement) String | StringStatement String

numOfLeafCommandDescendents : Statement -> Int
numOfLeafCommandDescendents statement =
  if isRenderable statement then
    case statement of
      Command name content rawContent ->
        if hasNoCommandChildren statement then
          1
        else
          sum (map numOfLeafCommandDescendents content)
      _ ->
        0
  else
    0

isRenderable : Statement -> Bool
isRenderable statement =
  case statement of
    StringStatement rawContent ->
      False
    Command name content rawContent ->
      case name of
        "hidden" ->
          False
        _ ->
          True

hasNoCommandChildren : Statement -> Bool
hasNoCommandChildren statement =
  case statement of
    StringStatement rawContent ->
      False
    Command name content rawContent ->
      all isACommand content

isACommand : Statement -> Bool
isACommand statement =
  case statement of
    StringStatement rawContent ->
      False
    Command name content rawContent ->
      True
