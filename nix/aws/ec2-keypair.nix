{ config, name, lib, ... }:

with lib;

{
  options = {

    name = mkOption {
      default = "charon-${name}";
      type = types.str;
      description = "Name of the EC2 key pair.";
    };

    region = mkOption {
      type = types.str;
      description = "Amazon EC2 region.";
    };

    accessKeyId = mkOption {
      default = "";
      type = types.str;
      description = "The AWS Access Key ID.";
    };

    privateKeyFile = mkOption {
      default = "";
      description = "Key to import";
    };

  };

  config._type = "ec2-keypair";
}