Upcast is a set of nix-based linux deployment platform tools and cloud infrastructure (IaaS) automation tools.

[![Build Status](https://travis-ci.org/zalora/upcast.svg?branch=master)](https://travis-ci.org/zalora/upcast)

It consists of (see [Features](#features) for details):
- `infra` - AWS infrastructure based on a [declarative spec](test/big-network.nix) in [Nix](http://nixos.org/nix/) expression language
- [opinionated base NixOS configuration](nix/nixos) suitable for cloud deployments based on [EC2 instance-store instances](nix/nixos/env-ec2.nix)
  (see also the [list of AMIs](nix/aws/ec2-amis.nix))
  and [VirtualBox](nix/nixos/env-virtualbox.nix) for development/testing
- nix-based tools for PaaS-style software deployment and build support - `build-remote` and `install`
- tools to bootstrap Nix on non-NixOS systems

The ultimate goal of Upcast is to make you stop thinking about deployments and focus on your apps instead.
Upcast's CLI interface is designed to be composed with other tools.
Every Upcast feature so far has appeared from the need to improve day-to-day operations.

### Features

#### Deploying NixOS on Upcast-provisioned AWS infrastructure

```console
% cabal install
```

Contents of `infra.nix`:
```nix
{ lib ? import <upcast/lib> }:
let
  ec2-args = {
    accessKeyId = "default";
    region = "eu-west-1";
    zone = "eu-west-1a";
    securityGroups = [ "sg-bbbbbbbb" ];
    subnet = "subnet-ffffffff";
    keyPair = "my-keypair";
  };
  instance = instanceType: ec2-args // { inherit instanceType; };
in
{
  infra = {
    ec2-instance = {
      node1 = instance "m3.large";
      node2 = instance "m3.large";
      ubuntu = instance "m3.large" // {
        # http://cloud-images.ubuntu.com/locator/ec2/
        ami = "ami-befc43c9";
      };
    };
  };

  # you need <nixpkgs> in your $NIX_PATH to build this
  # <upcast/nixos> is a drop-in replacement for <nixpkgs/nixos>
  some-image = (import <upcast/nixos> {
    configuration = { config, pkgs, lib, ... }: {
      config.services.nginx.enable = true;
    };
  }).system;
}
```

`upcast infra-tree` dumps the full json configuration of what's going to be provisioned,
note that upcast only evaluates the top level `infra` attribute.

`upcast infra` actually provisions all resources and outputs the `ssh_config(5)` for all compute
nodes in the spec. It also writes a `.store` file with the infra state, which is a text file -
you can commit it into your VCS which is great for scaling your teamwork.

Note that the infrastructure spec is evaluated separately from NixOS system closure unlike NixOps
(installation must also be handled separately and is outside of `upcast` cli tool).

```console
% upcast infra-tree infra.nix | jq -r .

% upcast infra infra.nix > ssh_config
```

`upcast build-remote` and `upcast install` are wrappers over Nix/NixOS toolchain.
Here they are used to build a NixOS system closure and install it on `node1`.

```console
% upcast build-remote -t hydra -A some-image infra.nix \
    | xargs -tn1 upcast install -c ssh_config -f hydra -t node1 
```

Same example without `build-remote`:

```console
% nix-build -I upcast=$(upcast nix-path) -A some-image -A some-image infra.nix
% upcast install -c ssh_config -t node1 $(readlink ./result)
```

For other examples see [nix-adhoc](https://github.com/proger/nix-adhoc) and upcast [tests](test).

#### Remote builds

> tl;dr: you really *need* to do this if you're using a Mac and/or like visiting Starbucks

Unlike [Nix distributed builds](http://nixos.org/nix/manual/#chap-distributed-builds)
packages are not copied back and forth between the instance and your local machine.

```bash
upcast build-remote -t hydra.com -A something default.nix
```

If you want to update your existing systems as part of your CI workflow, you can do something like this:

```bash
upcast infra examples/vpc-nix-instance.nix > ssh_config

awk '/^Host/{print $2}' ssh_config | \
    xargs -I% -P4 -n1 -t ssh -F ssh_config % nix-collect-garbage -d

awk '/^Host/{print $2}' ssh_config | \
    xargs -I% -P4 -n1 -t upcast install -t % $(upcast build-remote -A some-system blah.nix)
```

#### Nix profile installs

Read more about Nix profiles [here](http://nixos.org/nix/manual/#sec-profiles).

Profiles are used by NixOS to pin a root system path to a known location.

You can use nix profiles to pin your own packages (or collection of packages using functions like 
[buildEnv](https://github.com/NixOS/nixpkgs/blob/d232390d5dc3dcf912e76ea160aea62f049918e1/pkgs/build-support/buildenv/default.nix)).

For example, install a random package and pin it to a `hello` profile:

```bash
upcast build-remote -t hydra -A my-package default.nix | xargs -n1t upcast install -f hydra -p /nix/var/nix/profiles/hello -t target-instance
```

Assuming `my-package` contains `bin/program` you can run it like: `/nix/var/nix/profiles/per-user

Or, install a system closure to any NixOS system (i.e. update `system` profile) and switch to it:

```bash
# assuming the closure was built earlier
upcast install -t ec2-55-99-44-111.eu-central-1.compute.amazonaws.com /nix/store/72q9sd9an61h0h1pa4ydz7qa1cdpf0mj-nixos-14.10pre-git
```

#### Using Nix on non-NixOS Linux systems

Read [nix-install](bootstrap/nix-install) first.

```console
% cat bootstrap/nix-install | ssh centos
```

#### Improving latency: OpenSSH shared connections

Not really an Upcast feature, but a hint.

`ControlMaster` helps speed up subsequent ssh sessions by reusing a single TCP connection. See [ssh_config(5)](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man5/ssh_config.5?query=ssh_config).

```console
% cat ~/.ssh/config
Host *
    ControlPath ~/.ssh/master-%r@%h:%p
    ControlMaster auto
    ControlPersist yes
```

### Known issues

- state files are not garbage collected, have to be often cleaned up manually;
- altering infra state is not supported properly (you need to remove using aws cli, cleanup the state file and try again);
- word "aterm" is naming a completely different thing throughout the code;

Note: the app is currently in HEAVY development (and is already being used to power production cloud instances)
so some interfaces may break without notice until the initial release.

### More stuff

The AWS client code now lives in its own library: [zalora/aws-ec2](https://github.com/zalora/aws-ec2).
