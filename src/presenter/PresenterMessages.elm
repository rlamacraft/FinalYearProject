module PresenterMessages exposing (..)
{-
  Expose Msg for the Presenter window so is available in all modules that render HTML
-}

type Msg = Received String | ForwardTransition
