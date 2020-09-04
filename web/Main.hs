{-# language NamedFieldPuns    #-}
{-# language OverloadedStrings #-}
{-# language RecordWildCards   #-}

module Main where

import Miso
import Miso.String (MisoString)

main :: IO ()
main = startApp App { .. }
  where
    initialAction = None
    model         = Model { }
    update        = updateModel
    view          = viewModel
    events        = defaultEvents
    subs          = []
    mountPoint    = Nothing
    logLevel      = Off

data Model
  = Model { }
  deriving (Show, Eq)

data Action
  = None
  deriving (Show, Eq)

updateModel :: Action -> Model -> Effect Action Model
updateModel _ m = noEff m

bootstrapUrl :: MisoString
bootstrapUrl = "https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css"

viewModel :: Model -> View Action
viewModel Model {  }
  = div_ []
      [ text "Hello from Miso!"
      , link_ [ rel_ "stylesheet"
              , href_ bootstrapUrl ]
      ]