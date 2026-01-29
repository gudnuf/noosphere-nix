# Next.js development server proxy configuration
# Allows serving Next.js dev servers at custom URL paths
{ config, lib, ... }:

let
  cfg = config.services.nextjsDev;

  # Generate nginx location blocks for each app
  mkAppLocations = name: appCfg: {
    "/${appCfg.path}" = {
      proxyPass = "http://127.0.0.1:${toString appCfg.port}/${appCfg.path}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
    "/${appCfg.path}/" = {
      proxyPass = "http://127.0.0.1:${toString appCfg.port}/${appCfg.path}/";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
    # Handle Next.js _next static files and HMR
    "~ ^/${appCfg.path}/_next/(.*)$" = {
      proxyPass = "http://127.0.0.1:${toString appCfg.port}/${appCfg.path}/_next/$1$is_args$args";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };

  # Merge all app locations
  allLocations = lib.foldl' (acc: name: acc // mkAppLocations name cfg.apps.${name}) {} (lib.attrNames cfg.apps);
in
{
  options.services.nextjsDev = {
    enable = lib.mkEnableOption "Next.js development server proxying";

    apps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          path = lib.mkOption {
            type = lib.types.str;
            description = "URL path prefix (without leading slash)";
            example = "myapp";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 3000;
            description = "Port the Next.js dev server runs on";
          };
        };
      });
      default = {};
      description = "Next.js apps to proxy";
      example = lib.literalExpression ''
        {
          woodworks = {
            path = "goodenoughwoodworks";
            port = 3000;
          };
        }
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.apps != {}) {
    # Add locations to the default nginx virtual host
    services.nginx.virtualHosts."blog".locations = allLocations;
  };
}
