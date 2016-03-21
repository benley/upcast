{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ImplicitParams #-}

module Upcast.Deploy where

import qualified Upcast.Shell as Shell
import           Upcast.Shell (Commandline, (<>), env, render,
                               args, maybeKey, exec)
import           Upcast.Types (StorePath, Remote(..),
                               Install(..), NixContext(..))

ssh :: (?sshConfig :: Maybe FilePath) => String -> Commandline -> Commandline
ssh host = Shell.ssh host sshBaseOptions

nixSshEnv :: (?sshConfig :: Maybe FilePath) => Commandline -> Commandline
nixSshEnv = env [("NIX_SSHOPTS", render (args sshBaseOptions))]

sshBaseOptions :: (?sshConfig :: Maybe FilePath) => [String]
sshBaseOptions = [ "-A"
                 , "-o", "StrictHostKeyChecking=no"
                 , "-o", "UserKnownHostsFile=/dev/null"
                 , "-o", "PasswordAuthentication=no"
                 , "-o", "PreferredAuthentications=publickey"
                 , "-x"
                 ] <> maybeKey "-F" ?sshConfig

nixRealise :: StorePath -> Commandline
nixRealise drv = exec "nix-store" ["--realise", drv]

nixSetProfile :: FilePath -> StorePath -> Commandline
nixSetProfile i_profile i_storepath =
    exec "nix-env" ["-p", i_profile, "--set", i_storepath]

nixClosure :: FilePath -> Commandline
nixClosure path = exec "nix-store" ["-qR", path]

nixCopyClosureTo :: (?sshConfig :: Maybe FilePath) => String -> FilePath -> Commandline
nixCopyClosureTo "localhost" path = exec "ls" ["-ld", "--", path]
nixCopyClosureTo host path = nixSshEnv (exec "nix-copy-closure" [ "--gzip"
                                                                , "--to", host
                                                                , path
                                                                ])

nixSystemProfile :: FilePath
nixSystemProfile = "/nix/var/nix/profiles/system"
