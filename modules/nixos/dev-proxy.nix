# Development proxy with port-based routing
# Allows accessing localhost services via https://dev.domain.com/PORT/path
{ config, lib, ... }:

let
  cfg = config.services.devProxy;
  # Build regex pattern for allowed ports: (3000|3001|5173|...)
  portPattern = lib.concatMapStringsSep "|" toString cfg.allowedPorts;
in
{
  options.services.devProxy = {
    enable = lib.mkEnableOption "Development port-based proxy";

    domain = lib.mkOption {
      type = lib.types.str;
      description = "Full domain for dev proxy (e.g., dev.example.com)";
      example = "dev.example.com";
    };

    allowedPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 3000 3001 4000 5000 5173 8000 8080 8888 ];
      description = ''
        Localhost ports allowed to be proxied.
        Only these ports can be accessed via the dev proxy for security.
      '';
    };

    basicAuth = {
      enable = lib.mkEnableOption "basic authentication for dev proxy";

      htpasswdFile = lib.mkOption {
        type = lib.types.path;
        default = "/etc/nginx/.htpasswd-dev";
        description = ''
          Path to htpasswd file for basic auth.
          Generate with: htpasswd -c /etc/nginx/.htpasswd-dev username
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure SSL module is enabled (we need ACME)
    assertions = [
      {
        assertion = config.services.ssl.enable;
        message = "services.devProxy requires services.ssl to be enabled";
      }
    ];

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;

      # Optional basic auth
      basicAuthFile = lib.mkIf cfg.basicAuth.enable cfg.basicAuth.htpasswdFile;

      # Port-based routing: /PORT/path -> localhost:PORT/path
      # Uses nginx named captures and proxy_pass
      locations."~ ^/(${portPattern})(/.*)?$" = {
        proxyPass = "http://127.0.0.1:$1$2";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Port $server_port;

          # Handle empty path (e.g., /3000 -> /3000/)
          # The $2 capture will be empty, proxy to root
          proxy_redirect ~^(http://[^/]+)(/.*)$ $scheme://$host/$1$2;
        '';
      };

      # Root location - show help page
      locations."/" = {
        extraConfig = ''
          default_type text/html;
          return 200 '<!DOCTYPE html>
          <html>
          <head><title>Dev Proxy</title>
          <style>
            body { font-family: system-ui, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
            h1 { color: #333; }
            code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
            ul { line-height: 2; }
          </style>
          </head>
          <body>
            <h1>Dev Proxy Active</h1>
            <p>Access localhost services via URL path:</p>
            <ul>
              <li><code>https://${cfg.domain}/3000/</code> &rarr; <code>localhost:3000</code></li>
              <li><code>https://${cfg.domain}/5173/api</code> &rarr; <code>localhost:5173/api</code></li>
            </ul>
            <p><strong>Allowed ports:</strong> ${lib.concatMapStringsSep ", " toString cfg.allowedPorts}</p>
          </body>
          </html>';
        '';
      };
    };
  };
}
