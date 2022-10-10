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


# Useful information

### Cardano-node config files

- https://hydra.iohk.io/build/13695229/download/1/index.html
- https://developers.cardano.org/docs/stake-pool-course/handbook/run-cardano-node-handbook/
- As pointed in cardano-node repo: https://book.world.dev.cardano.org/environments.html

### Mainnet era boundaries
| Era bound          | SlotNo    | Hash                                                             |
|--------------------|-----------|------------------------------------------------------------------|
| Last Byron Block   | 4492799   | f8084c61b6a238acec985b59310b6ecec49c0ab8352249afd7268da5cff2a457 |
| Last Shelley Block | 16588737  | 4e9bbbb67e3ae262133d94c3da5bffce7b1127fc436e7433b87668dba34c354a |
| Last Allegra Block | 23068793  | 69c44ac1dda2ec74646e4223bc804d9126f719b1c245dadc2ad65e8de1b276d7 |
| Last Mary Block    | 39916796  | e72579ff89dc9ed325b723a33624b596c08141c7bd573ecfff56a1f7229e4d09 |

### Testnet era boundaries
| Era bound          | SlotNo    | Hash                                                             |
|--------------------|-----------|------------------------------------------------------------------|
| Last Byron block   | 1598399   | 7e16781b40ebf8b6da18f7b5e8ade855d6738095ef2f1c58c77e88b6e45997a4 |
| Last Shelley block | 13694363  | b596f9739b647ab5af901c8fc6f75791e262b0aeba81994a1d622543459734f2 |
| Last Allegra block | 18014387  | 9914c8da22a833a777d8fc1f735d2dbba70b99f15d765b6c6ee45fe322d92d93 |
| Last Mary block    | 36158304  | 2b95ce628d36c3f8f37a32c2942b48e4f9295ccfe8190bcbc1f012e1e97c79eb |
| Last Alonzo block  | 62510369  | d931221f9bc4cae34de422d9f4281a2b0344e86aac6b31eb54e2ee90f44a09b9 |


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

# To-do (and probably, wont-do)
- Proper nixification
- Benchmarks
