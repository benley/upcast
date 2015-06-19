{-# LANGUAGE DeriveGeneric #-}

module Upcast.Infra.NixTypes where

--
-- This file is autogenerated. Do not edit. I'm sorry.
--

import GHC.Generics
import Control.Applicative
import Data.Char (toLower)
import Data.Text (Text)
import Data.Map.Strict (Map)
import Data.Aeson
import Data.Aeson.Types

type Attrs = Map Text

data AccessLog = AccessLog
      { accessLog_emitInterval :: Integer
      , accessLog_enable :: Bool
      , accessLog_s3BucketName :: Text
      , accessLog_s3BucketPrefix :: Text
      } deriving (Show, Generic)

instance FromJSON AccessLog where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 10 }

instance ToJSON AccessLog where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 10 }


data BlockDeviceMapping = BlockDeviceMapping
      { blockDeviceMapping_blockDeviceMappingName :: Text
      , blockDeviceMapping_disk :: InfraRef Ebs
      , blockDeviceMapping_fsType :: Text
      } deriving (Show, Generic)

instance FromJSON BlockDeviceMapping where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 19 }

instance ToJSON BlockDeviceMapping where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 19 }


data ConnectionDraining = ConnectionDraining
      { connectionDraining_enable :: Bool
      , connectionDraining_timeout :: Integer
      } deriving (Show, Generic)

instance FromJSON ConnectionDraining where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 19 }

instance ToJSON ConnectionDraining where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 19 }


data Ebs = Ebs
      { ebs_accessKeyId :: Text
      , ebs_name :: Text
      , ebs_region :: Text
      , ebs_size :: Integer
      , ebs_snapshot :: Maybe Text
      , ebs_volumeType :: VolumeType
      , ebs_zone :: Text
      } deriving (Show, Generic)

instance FromJSON Ebs where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 4 }

instance ToJSON Ebs where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 4 }


data Ec2instance = Ec2instance
      { ec2instance_accessKeyId :: Text
      , ec2instance_ami :: Text
      , ec2instance_blockDeviceMapping :: Attrs BlockDeviceMapping
      , ec2instance_ebsBoot :: Bool
      , ec2instance_ebsOptimized :: Bool
      , ec2instance_instanceProfileARN :: Maybe Text
      , ec2instance_instanceType :: Text
      , ec2instance_keyPair :: InfraRef Ec2keypair
      , ec2instance_region :: Text
      , ec2instance_securityGroups :: [InfraRef Ec2sg]
      , ec2instance_subnet :: Maybe (InfraRef Ec2subnet)
      , ec2instance_userData :: Attrs Text
      , ec2instance_zone :: Text
      } deriving (Show, Generic)

instance FromJSON Ec2instance where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 12 }

instance ToJSON Ec2instance where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 12 }


data Ec2keypair = Ec2keypair
      { ec2keypair_accessKeyId :: Text
      , ec2keypair_name :: Text
      , ec2keypair_privateKeyFile :: Text
      , ec2keypair_region :: Text
      } deriving (Show, Generic)

instance FromJSON Ec2keypair where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 11 }

instance ToJSON Ec2keypair where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 11 }


data Ec2sg = Ec2sg
      { ec2sg_accessKeyId :: Text
      , ec2sg_description :: Text
      , ec2sg_name :: Text
      , ec2sg_region :: Text
      , ec2sg_rules :: [Rule]
      , ec2sg_vpc :: Maybe (InfraRef Ec2vpc)
      } deriving (Show, Generic)

instance FromJSON Ec2sg where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 6 }

instance ToJSON Ec2sg where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 6 }


data Ec2subnet = Ec2subnet
      { ec2subnet_accessKeyId :: Text
      , ec2subnet_cidrBlock :: Text
      , ec2subnet_region :: Text
      , ec2subnet_vpc :: InfraRef Ec2vpc
      , ec2subnet_zone :: Text
      } deriving (Show, Generic)

instance FromJSON Ec2subnet where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 10 }

instance ToJSON Ec2subnet where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 10 }


data Ec2vpc = Ec2vpc
      { ec2vpc_accessKeyId :: Text
      , ec2vpc_cidrBlock :: Text
      , ec2vpc_region :: Text
      } deriving (Show, Generic)

instance FromJSON Ec2vpc where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 7 }

instance ToJSON Ec2vpc where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 7 }


data Elb = Elb
      { elb_accessKeyId :: Text
      , elb_accessLog :: AccessLog
      , elb_connectionDraining :: ConnectionDraining
      , elb_crossZoneLoadBalancing :: Bool
      , elb_healthCheck :: HealthCheck
      , elb_instances :: [InfraRef Ec2instance]
      , elb_internal :: Bool
      , elb_listeners :: [Listener]
      , elb_name :: Text
      , elb_region :: Text
      , elb_route53Aliases :: Attrs Route53Alias
      , elb_securityGroups :: [InfraRef Ec2sg]
      , elb_subnets :: [InfraRef Ec2subnet]
      } deriving (Show, Generic)

instance FromJSON Elb where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 4 }

instance ToJSON Elb where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 4 }


data HealthCheck = HealthCheck
      { healthCheck_healthyThreshold :: Integer
      , healthCheck_interval :: Integer
      , healthCheck_target :: Target
      , healthCheck_timeout :: Integer
      , healthCheck_unhealthyThreshold :: Integer
      } deriving (Show, Generic)

instance FromJSON HealthCheck where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 12 }

instance ToJSON HealthCheck where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 12 }


data HealthCheckPathTarget = HealthCheckPathTarget
      { healthCheckPathTarget_path :: Text
      , healthCheckPathTarget_port :: Integer
      } deriving (Show, Generic)

instance FromJSON HealthCheckPathTarget where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 22 }

instance ToJSON HealthCheckPathTarget where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 22 }


data Listener = Listener
      { listener_instancePort :: Integer
      , listener_instanceProtocol :: Text
      , listener_lbPort :: Integer
      , listener_lbProtocol :: Text
      , listener_sslCertificateId :: Text
      , listener_stickiness :: Maybe Stickiness
      } deriving (Show, Generic)

instance FromJSON Listener where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 9 }

instance ToJSON Listener where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 9 }


data Route53Alias = Route53Alias
      { route53Alias_zoneId :: Text
      } deriving (Show, Generic)

instance FromJSON Route53Alias where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 13 }

instance ToJSON Route53Alias where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 13 }


data Rule = Rule
      { rule_codeNumber :: Maybe Integer
      , rule_fromPort :: Maybe Integer
      , rule_protocol :: Text
      , rule_sourceGroupName :: Maybe Text
      , rule_sourceGroupOwnerId :: Maybe Text
      , rule_sourceIp :: Maybe Text
      , rule_toPort :: Maybe Integer
      , rule_typeNumber :: Maybe Integer
      } deriving (Show, Generic)

instance FromJSON Rule where
  parseJSON = genericParseJSON defaultOptions
              { fieldLabelModifier = drop 5 }

instance ToJSON Rule where
  toJSON = genericToJSON defaultOptions
           { fieldLabelModifier = drop 5 }


data Stickiness = App Text | Lb (Maybe Integer) deriving (Show, Generic)

instance FromJSON Stickiness where
  parseJSON = genericParseJSON defaultOptions
              { sumEncoding = ObjectWithSingleField, constructorTagModifier = map toLower }
instance ToJSON Stickiness where
  toJSON = genericToJSON defaultOptions
           { sumEncoding = ObjectWithSingleField, constructorTagModifier = map toLower }

data Target = Http HealthCheckPathTarget | Https HealthCheckPathTarget | Ssl Integer | Tcp Integer deriving (Show, Generic)

instance FromJSON Target where
  parseJSON = genericParseJSON defaultOptions
              { sumEncoding = ObjectWithSingleField, constructorTagModifier = map toLower }
instance ToJSON Target where
  toJSON = genericToJSON defaultOptions
           { sumEncoding = ObjectWithSingleField, constructorTagModifier = map toLower }

data VolumeType = Gp2 | Iop Integer | Standard deriving (Show, Generic)

instance FromJSON VolumeType where
  parseJSON = genericParseJSON defaultOptions
              { sumEncoding = ObjectWithSingleField, constructorTagModifier = map toLower }
instance ToJSON VolumeType where
  toJSON = genericToJSON defaultOptions
           { sumEncoding = ObjectWithSingleField, constructorTagModifier = map toLower }


data InfraRef a = RefLocal Text | RefRemote Text deriving (Show, Generic)

instance FromJSON (InfraRef a) where
  parseJSON = genericParseJSON defaultOptions
              { sumEncoding = ObjectWithSingleField
              , constructorTagModifier = drop 3 . map toLower
              }

instance ToJSON (InfraRef a) where
  toJSON = genericToJSON defaultOptions
           { sumEncoding = ObjectWithSingleField
           , constructorTagModifier = drop 3 . map toLower
           }

data Infras = Infras
      { infraRealmName :: Text
      , infraRegions :: [Text]
      , infraEbs :: Attrs Ebs
      , infraEc2instance :: Attrs Ec2instance
      , infraEc2keypair :: Attrs Ec2keypair
      , infraEc2sg :: Attrs Ec2sg
      , infraEc2subnet :: Attrs Ec2subnet
      , infraEc2vpc :: Attrs Ec2vpc
      , infraElb :: Attrs Elb
      } deriving (Show, Generic)

instance FromJSON Infras where
  parseJSON (Object o) =
      Infras <$>
      o .: "realm-name" <*>
      o .: "regions" <*>
      o .: "ebs" <*>
      o .: "ec2-instance" <*>
      o .: "ec2-keypair" <*>
      o .: "ec2-sg" <*>
      o .: "ec2-subnet" <*>
      o .: "ec2-vpc" <*>
      o .: "elb"
  parseJSON _ = empty
