# Blog service configuration
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.services.blog;
  blogPkg = inputs.the-blog.packages.${pkgs.system}.default;
in
{
  imports = [ inputs.the-blog.nixosModules.default ];
  options.services.blog = {
    enable = lib.mkEnableOption "the blog";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Domain name for the blog (empty for IP-only access)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3311;
      description = "Internal port for the blog server";
    };
  };

  config = lib.mkIf cfg.enable {
    # Configure the blog service
    services.rust-blog = {
      enable = true;
      package = blogPkg;
      host = "127.0.0.1";
      port = cfg.port;
      # Use content from the package (from GitHub)
      contentPath = "${blogPkg}/share/blog-server/content";
      logLevel = "info";
    };

    # Nginx reverse proxy
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;

      virtualHosts."blog" = {
        default = true;
        serverName = if cfg.domain != "" then cfg.domain else "_";
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    # Open firewall for HTTP
    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
