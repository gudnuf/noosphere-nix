# Blog service configuration
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.services.blog;
  sslEnabled = config.services.ssl.enable;
  blogPkg = inputs.the-blog.packages.${pkgs.system}.default;
in
{
  imports = [ inputs.the-blog.nixosModules.default ];

  options.services.blog = {
    enable = lib.mkEnableOption "the blog";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Domain name for the blog.
        If empty and SSL is disabled, serves on all hostnames.
        If empty and SSL is enabled, you must set a domain.
      '';
      example = "blog.example.com";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3311;
      description = "Internal port for the blog server";
    };

    forceSSL = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Redirect HTTP to HTTPS when SSL is enabled";
    };
  };

  config = lib.mkIf cfg.enable {
    # Validation
    assertions = [
      {
        assertion = !sslEnabled || cfg.domain != "";
        message = "services.blog.domain must be set when services.ssl is enabled";
      }
    ];

    # Configure the blog service
    services.rust-blog = {
      enable = true;
      package = blogPkg;
      host = "127.0.0.1";
      port = cfg.port;
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

        # SSL configuration when enabled
        enableACME = sslEnabled && cfg.domain != "";
        forceSSL = sslEnabled && cfg.forceSSL && cfg.domain != "";

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    # Open firewall for HTTP (always needed for ACME challenges too)
    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
