module Statement exposing (Statement(..), leafCommandCount, isRenderableCommand, hasNoCommandChildren)

import List exposing (sum,map,any)

type Statement = Command String (List Statement) String | StringStatement String

leafCommandCount : Statement -> Int
leafCommandCount statement =
  if isRenderableCommand statement then
    case statement of
      Command name content rawContent ->
        if hasNoCommandChildren statement then
          1
        else
          sum (map leafCommandCount content)
      _ ->
        0
  else
    0

isRenderableCommand : Statement -> Bool
isRenderableCommand statement =
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
      True
    Command name content rawContent ->
      not <| any isACommand content

isACommand : Statement -> Bool
isACommand statement =
  case statement of
    StringStatement rawContent ->
      False
    Command name content rawContent ->
      True
