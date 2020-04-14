{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
module Main (main) where

import Lib (app, initConnectionPool)
import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON
import System.Process
import Database.PostgreSQL.Typed
import Data.Pool
import DatabaseConnection
import Servant

main :: IO ()
main = do
  dbURI <- readProcess "pg_tmp" ["-t", "-w", "5"] []
  dbPool <- initConnectionPool $ parseDbURI dbURI
  callProcess "sqitch" ["deploy", "--target", dbURI]
  withResource dbPool seedDB
  hspec (spec $ app dbPool)

seedDB :: PGConnection -> IO Int
seedDB db = pgExecute db [pgSQL|INSERT INTO users (first_name, last_name) VALUES ('Isaac', 'Newton'), ('Albert', 'Einstein')|]

spec :: Application -> Spec
spec app =
  with (return app) $
  describe "GET /users" $
  it "responds with [User]" $ do
    let users =
          [json|[{userFirstName:"Isaac",userLastName:"Newton",userId:1},{userFirstName:"Albert",userLastName:"Einstein",userId:2}]|]
    get "/users" `shouldRespondWith` users
