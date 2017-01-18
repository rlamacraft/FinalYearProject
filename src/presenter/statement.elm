module Statement exposing (Statement(..), numOfChildCommands)

import List exposing (sum,map)

type Statement = Command String (List Statement) String | StringStatement String

-- TODO: memoise as will be used with each render but rarely change
numOfChildCommands : Statement -> Int
numOfChildCommands statement =
  sumCommands statement - 1

sumCommands : Statement -> Int
sumCommands statement =
 case statement of
    StringStatement rawContent ->
      0
    Command name content rawContent ->
      sum ( map sumCommands content ) + 1
