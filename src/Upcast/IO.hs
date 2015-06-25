{-# LANGUAGE ConstraintKinds #-}

module Upcast.IO (
  module System.IO
, ASCIIColor(..)
, applyColor
, oops
, expect
, srsly
, expectRight
, warn
, warn8
, pprint
, Str
, toString
, args
, squote
, dquote
, env
) where

import           System.IO
import           System.IO.Unsafe (unsafePerformIO)
import           System.Exit (ExitCode(..))
import           Control.Exception

import qualified Data.ByteString.Char8 as B8
import qualified Data.ByteString.Lazy.Char8 as LBS
import           Data.Maybe (fromMaybe)
import           Data.Monoid (Monoid, mconcat, (<>))
import           Data.String (IsString)

import           Data.List (intersperse)

import           Text.Read (readMaybe)

import           Data.Aeson.Types (ToJSON)
import           Data.Aeson.Encode.Pretty (encodePretty)

data ASCIIColor = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
                deriving (Enum)

needsColor :: Bool
needsColor = unsafePerformIO $ hIsTerminalDevice stderr

applyColor :: ASCIIColor -> String -> String
applyColor color s = case needsColor of
                         True -> "\ESC[1;" ++ colorCode ++ "m" ++ s ++ "\ESC[0m"
                         False -> s
  where
    colorCode = show $ 30 + fromEnum color


oops :: String -> IO a
oops = throwIO . ErrorCall

expect :: Eq a => a -> String -> IO a -> IO ()
expect value excuse action = do
  result <- action
  case result of
      x | x == value -> return ()
      _ -> oops excuse

srsly :: String -> IO ExitCode -> IO ()
srsly = expect ExitSuccess

expectRight :: Show left => IO (Either left a) -> IO a
expectRight action = do
  result <- action
  case result of
      Right smth -> return smth
      Left err -> oops (show err)

warn :: [String] -> IO ()
warn = hPutStrLn stderr . mconcat

warn8 :: [B8.ByteString] -> IO ()
warn8 = B8.hPutStrLn stderr . mconcat

pprint :: ToJSON a => a -> IO ()
pprint = LBS.putStrLn . encodePretty


type Str a = (IsString a, Show a)

toString :: Show a => a -> String
toString s = let s' = show s in fromMaybe s' (readMaybe s')

args :: (IsString a, Monoid a) => [a] -> a
args = mconcat . intersperse " "

squote :: Str a => a -> String
squote a = mconcat ["'", toString a, "'"]

dquote :: Str a => a -> String
dquote a = mconcat ["\"", toString a, "\""]

env :: Str a => [(String, a)] -> String
env = args . ("env":) . mconcat . fmap (\(k, v) -> [k, "=", squote v])
