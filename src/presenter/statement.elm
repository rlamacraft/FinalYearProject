module Statement exposing (Statement(..), numOfLeafCommandDescendents)

import List exposing (sum,map,all)

type Statement = Command String (List Statement) String | StringStatement String

numOfLeafCommandDescendents : Statement -> Int
numOfLeafCommandDescendents statement =
  case statement of
    StringStatement rawContent ->
      0
    Command name content rawContent ->
      if hasNoCommandChildren statement then
        1
      else
        sum (map numOfLeafCommandDescendents content)

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
