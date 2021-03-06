{-# LANGUAGE TupleSections #-}
{-# LANGUAGE ConstraintKinds  #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RecordWildCards  #-}

module Infracast.Machine
( Machine(..)
, machines
, machines2ssh
, machines2nix
) where

import qualified Algorithms.NaturalSort as N
import           Control.Applicative ((<$>))
import           Control.Lens
import           Control.Monad.State (gets)
import           Data.Function (on)
import           Data.List (find, intercalate, sortBy)
import           Data.Monoid ((<>), mconcat, mempty)
import           Data.Text (Text)
import           Data.Witherable (catMaybes)
import           Infracast.Amazonka (AWS, State(..))
import           Infracast.NixTypes (Ec2keypair(..))
import qualified Network.AWS.EC2.Types as EC2
import           Upcast.Shell (toString)


data Machine =
  Machine
  { m_hostname :: Text
  , m_publicIp :: Text
  , m_privateIp :: Text
  , m_instanceId :: Text
  , m_keyFile :: Maybe Text
  } deriving (Show)

machines :: AWS m => m [Machine]
machines = fmap catMaybes . map . toMachine <$> gets stateKeyPairs >>= (<$> gets stateInstances)

toMachine :: [Ec2keypair] -> EC2.Instance -> Maybe Machine
toMachine keypairs inst = do
  m_hostname   <- inst ^? EC2.insTags . folded . filtered ((== "Name") . view EC2.tagKey) . EC2.tagValue
  m_publicIp   <- inst ^. EC2.insPublicIPAddress
  m_privateIp  <- inst ^. EC2.insPrivateIPAddress
  m_instanceId <- inst ^. EC2.insInstanceId & return
  m_keyFile    <- inst ^. EC2.insKeyName <&> \n -> find ((== n) . ec2keypair_name) keypairs
                                         <&> ec2keypair_privateKeyFile
  return Machine{..}

machines2ssh [] = ""
machines2ssh xs = machines2ssh' xs

machines2ssh' :: [Machine] -> String
machines2ssh' = (prefix <>) . intercalate "\n" . fmap config . sortBy (N.compare `on` m_hostname)
  where
    prefix = unlines [ "#"
                     , "# This file is automatically generated using `upcast infra'."
                     , "#"
                     , "UserKnownHostsFile=/dev/null"
                     , "StrictHostKeyChecking=no"
                     , ""
                     ]

    args :: Show a => (String, a) -> String
    args (k, v) = k <> " " <> toString v

    config Machine{..} = unlines [ args ("Host", m_hostname)
                                 , args ("  #", m_instanceId)
                                 , args ("  HostName", m_publicIp)
                                 , "  User root"
                                 , "  ControlMaster auto"
                                 , "  ControlPath ~/.ssh/master-%r@%h:%p"
                                 , "  ForwardAgent yes"
                                 , "  ControlPersist 60s"
                                 ] <> maybe mempty
                                      (args . ("  IdentityFile",)) m_keyFile

machines2nix :: [Machine] -> String
machines2nix = (<> suffix) . (prefix <>) . intercalate "\n" . fmap machine2nix . sortBy (N.compare `on` m_hostname)
  where
    prefix = unlines [ "#"
                     , "# This file is automatically generated using `upcast infra-nix'."
                     , "#"
                     , "{"
                     , "  instances = {"
                     ]
    suffix = "  };\n}\n"

    machine2nix Machine{..} = unlines $ fmap ("    " ++)
      [ mconcat [ toString m_hostname, " = {" ]
      , mconcat ["  instance-id = ", show m_instanceId, ";"]
      , mconcat ["  public-ip = ", show m_publicIp, ";"]
      , mconcat ["  private-ip = ", show m_privateIp, ";"]
      , mconcat ["  key-file = ", maybe "null" show m_keyFile, ";"]
      , "};"
      ]
