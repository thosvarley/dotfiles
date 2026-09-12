{ lib, ... }:
{
  services.mako = {
    enable = true;
    settings = {
      "default-timeout" = 5000;

      # Low-battery alerts (see battery-notify.nix) are sent at
      # urgency=critical specifically so they stand out in red and ignore
      # the default timeout -- they need to be dismissed on purpose.
      # Stylix already themes this section, so force our colors over it.
      "urgency=critical" = {
        "background-color" = lib.mkForce "#900000";
        "text-color" = lib.mkForce "#ffffff";
        "border-color" = lib.mkForce "#ff0000";
        "default-timeout" = lib.mkForce 0;
      };
    };
  };
}
