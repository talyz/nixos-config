{ pkgs, config, lib, ... }:

with lib;
with builtins;

let
  cfg = config.environment.persistence;
  
  # ["/home/user/" "/.screenrc"] -> ["home" "user" ".screenrc"]
  splitPath = paths:
    (filter (s: typeOf s == "string" && s != "")
            (concatMap (split "/") paths));
            
  # ["home" "user" ".screenrc"] -> "home/user/.screenrc"
  dirListToPath = dirList: (concatStringsSep "/" dirList);
  
  # ["/home/user/" "/.screenrc"] -> "/home/user/.screenrc"
  concatPaths = paths: (if hasPrefix "/" (head paths) then "/" else "") +
                         (dirListToPath (splitPath paths));
                         
  link = file: pkgs.runCommand "${replaceStrings ["/" "."] ["-" ""] file}" {}
                               "ln -s ${file} $out";
in
{
  options = {

    environment.persistence.etc = {

      targetDir = mkOption {
        type = types.str;
      };

      directories = mkOption {
        type = with types; listOf str;
        default = [];
      };

      files = mkOption {
        type = with types; listOf str;
        default = [];
      };

      createMissingDirectories = mkOption {
        type = types.bool;
        default = true;
      };
      
    };

    environment.persistence.root = {

      targetDir = mkOption {
        type = types.str;
      };

      directories = mkOption {
        type = with types; listOf str;
        default = [];
      };

      createMissingDirectories = mkOption {
        type = types.bool;
        default = true;
      };
      
    };
    
  };

  config = {
    environment.etc =
      listToAttrs
        (map (fileOrDir:
                nameValuePair
                  fileOrDir
                  { source = link (concatPaths [cfg.etc.targetDir fileOrDir]); })
             (cfg.etc.files ++ cfg.etc.directories));

    fileSystems =
      listToAttrs
        (map (dir:
                nameValuePair
                  (concatPaths ["/" dir])
                  {
                    device = concatPaths [cfg.root.targetDir dir];
                    options = ["bind"];
                  })
             cfg.root.directories);

    system.activationScripts =
      optionalAttrs cfg.etc.createMissingDirectories {
        createDirsInEtc = noDepEntry
                            (concatMapStrings
                               (dir: let targetDir = concatPaths [cfg.etc.targetDir dir]; in ''
                                 if [[ ! -e "${targetDir}" ]]; then
                                     mkdir -p "${targetDir}"
                                 fi
                               '')
                               cfg.etc.directories);
      } // optionalAttrs cfg.root.createMissingDirectories {
        createDirsInRoot = noDepEntry
                             (concatMapStrings
                                (dir: let targetDir = concatPaths [cfg.root.targetDir dir]; in ''
                                  if [[ ! -e "${targetDir}" ]]; then
                                      mkdir -p "${targetDir}"
                                  fi
                                '')
                                cfg.root.directories);
      };
  };
  
}
