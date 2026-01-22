# SSL/ACME configuration for Let's Encrypt certificates
{ config, lib, ... }:

let
  cfg = config.services.ssl;
in
{
  options.services.ssl = {
    enable = lib.mkEnableOption "SSL/ACME configuration";

    email = lib.mkOption {
      type = lib.types.str;
      description = "Email for Let's Encrypt notifications and account recovery";
      example = "admin@example.com";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = "Base domain name (e.g., example.com)";
      example = "example.com";
    };
  };

  config = lib.mkIf cfg.enable {
    # ACME / Let's Encrypt configuration
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = cfg.email;
        # Use HTTP-01 challenge (simplest, works without DNS API)
        # For wildcard certs, you'd need DNS-01 challenge
      };
    };

    # Nginx needs to be able to serve ACME challenges
    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
    };

    # Open HTTPS port
    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
