module Main where

import Lib
import System.Environment

main :: IO ()
main = do
  dbEnv <- lookupEnv "DB_URI"
  case dbEnv of
    Just uri -> startApp uri
    Nothing -> putStrLn "DB_URI env variable not set"
