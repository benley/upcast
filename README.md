Upcast is a declarative cloud infrastructure orchestration tool that leverages [Nix](http://nixos.org/nix/).
Its nix codebase (and, by extension, its interface) was started off by copying files from [nixops](https://github.com/nixos/nixops).

### Quick start

```console
upcast - infrastructure orchestratrion

Usage: upcast COMMAND

Available commands:
  run                      evaluate resources, run builds and deploy
  build                    perform a build of all machine closures
  ssh-config               dump ssh config for deployment (evaluates resources)
  resource-info            dump resource information in json format
  resource-debug           evaluate resources in debugging mode
```


```console
$ awk 'NR==1{print "default", $1, $2}' ~/.ec2-keys > ~/.aws-keys
$ cabal install
$ export UPCAST_NIX_FLAGS="--option use-binary-cache true --option binary-caches http://hydra.nixos.org"
$ upcast run my-network.nix -- -j4
```

See example deployments in `examples/`.

#### Configuring remote builds

Add the following to your shell profile:
```bash
export NIX_BUILD_HOOK="$HOME/.nix-profile/libexec/nix/build-remote.pl"
export NIX_REMOTE_SYSTEMS="$HOME/remote-systems.conf"
export NIX_CURRENT_LOAD="/tmp/remote-load"
```

### Goals

- simplicity, extensibility;
- shared state stored as nix expressions next to machines expressions;
- first-class AWS support (including AWS features nixops doesn't have);
- minimum dependency of network latency of the client;
- support for running day-to-day operations on deployed resources, services and machines.

### Notable differences from NixOps

#### Expression files

- You can no longer specify the machine environment using `deployment.targetEnv`, now you need to explicitly include the resource module instead.
  Currently available modules are: `<upcast/env-ec2.nix>`.

#### Operation modes

- The only supported command is `run` (so far). No `create`, `modify`, `clone`, `set-args`, `send-keys` non-sense;
- NixOps SQLite state files are abandoned, separate text files ([json dict for state](https://github.com/zalora/upcast/blob/master/src/Upcast/TermSubstitution.hs) and a private key file) are used instead;
- Physical specs are removed
  - Identical machines get identical machine closures, they are no longer parametric by things like hostnames (these are configured at runtime).

#### Resources

- New: EC2-VPC support, ELB support;
- Additionally planned: AWS autoscaling, EBS snapshotting;
- Different in EC2: CreateKeyPair (autogenerated private keys by amazon) is not supported, ImportKeyPair is used instead;
- Not supported: sqs, s3, elastic ips, ssh tunnels, adhoc nixos deployments,
                 deployments to expressions that span multiple AWS regions;
- Most likely will not be supported: virtualbox, hetzner, auto-luks, auto-raid0, `/run/keys` support, static route53 support (like nixops);

### Motivation

![motivation](http://i.imgur.com/HY2Gtk5.png)

### Known issues

- state files are not garbage collected, have to be often cleaned up manually;
- altering of most resources is not supported properly (you need to remove using aws cli, cleanup the state file and try again);
- word "aterm" is naming a completely different thing;

Note: the app is currently in HEAVY development (and is already being used to power production cloud instances)
so interfaces may break without notice.

### More stuff

The AWS client code now lives in its own library: [zalora/aws-ec2](https://github.com/zalora/aws-ec2).
