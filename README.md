# Usage

0. git submodule init && git submodule update
1. Use build scripts to build project. Executables wil be installed in ./bin
2. Start node if needed. Check node sync percentage with ./check-node-sync-<network>.
3. (Optional) create database if need
4. Use start scripts. 

# postgres databases (nixos)

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
