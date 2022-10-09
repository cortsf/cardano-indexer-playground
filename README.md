# Description
**WIP** Collection of easy to use scripts to quickly setup and experiment with multiple cardano chain indexers.

# Usage

0. init submodules in `./repos` with: `git submodule init && git submodule update`
1. Use `build_<something>.sh` scripts to build projects. Executables will be installed in `./bin`
2. Start node with `start_node_<network>.sh`. Check node sync % with `./check-node-sync-<network>.sh`.
3. (Optional) create database if needed
4. Use `start_<indexer>.sh` scripts. 
5. Make queries.

# Project structure
- bin: Executables built with `build_<something>.sh` scripts (not tracked by git).
- config: Config files for cardano node and indexers.
- data: Data generated by cardano node and indexers (not tracked by git).
- openapi-defs: Experimental clients generated from openAPI defs.
- repos: git submodules.
- results: Responses given after querying the indexers. 

# Cardano-node config files

- https://hydra.iohk.io/build/13695229/download/1/index.html
- https://developers.cardano.org/docs/stake-pool-course/handbook/run-cardano-node-handbook/
- As pointed in cardano-node repo: https://book.world.dev.cardano.org/environments.html

# Troubleshooting

- Cargo migrate error: https://github.com/dcSpark/carp/commit/98cec28b5cd17cb7040461091aa2382552169e92
- Cargo authentication error: https://sathias.gitlab.io/posts/2021/08/19/rust-cargo-resolve-authentication-issue.html

# Databases
### Postgres
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
### Redis
```
  services.redis.servers = {
    scrolls = {
      enable = true;
      port=6379;
    };
  };
```

# Notes
OpenAPI generated clients are experimental and (most likely) won't work.
