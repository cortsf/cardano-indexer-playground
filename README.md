# Usage

0. init submodules in ./repo with: git submodule init && git submodule update
1. Use build scripts to build projects. Executables will be installed in ./bin
2. Start node if needed. Check node sync percentage with ./check-node-sync-<*network*>.
3. (Optional) create database if needed
4. Use start scripts. 
5. Make queries.
# Cardano-node config files

- https://hydra.iohk.io/build/13695229/download/1/index.html
- https://developers.cardano.org/docs/stake-pool-course/handbook/run-cardano-node-handbook/
- As pointed in cardano-node repo: https://book.world.dev.cardano.org/environments.html

# Troubleshooting

## Cargo migrate error
https://github.com/dcSpark/carp/commit/98cec28b5cd17cb7040461091aa2382552169e92

## Cargo authentication error
https://sathias.gitlab.io/posts/2021/08/19/rust-cargo-resolve-authentication-issue.html

# Notes
OpenAPI generated clients are experimental and (most likely) won't work.

# Postgres databases (nixos)

```
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
       local all all trust
       host all all ::1/128 trust
     '';
    ensureDatabases = ["carp_mainnet" "carp_testnet" "ogmios_datum_cache"];
    ensureUsers = [
      {
        name = "carp";
        ensurePermissions = {
          "DATABASE carp_mainnet" = "ALL PRIVILEGES";
          "DATABASE carp_testnet" = "ALL PRIVILEGES";
        };
      }
      {
        name = "odc";
        ensurePermissions = {
          "DATABASE ogmios_datum_cache" = "ALL PRIVILEGES";
        };
      }
    ];
  };
```
