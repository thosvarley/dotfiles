{ pkgs, ... }:
let
  batteryNotify = pkgs.writeShellApplication {
    name = "battery-notify";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      bat=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' | head -n1)
      [ -z "$bat" ] && exit 0

      capacity=$(cat "$bat/capacity")
      status=$(cat "$bat/status")

      state_dir="''${XDG_RUNTIME_DIR:-/tmp}/battery-notify"
      mkdir -p "$state_dir"

      # Charging (or full) means the low-battery scare is over -- clear the
      # flags so the next real discharge re-triggers both notifications.
      if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
        rm -f "$state_dir/10" "$state_dir/5"
        exit 0
      fi

      if [ "$capacity" -le 5 ] && [ ! -f "$state_dir/5" ]; then
        notify-send -u critical -a "Battery" "Battery critical: $capacity%" "Plug in now."
        touch "$state_dir/5" "$state_dir/10"
      elif [ "$capacity" -le 10 ] && [ ! -f "$state_dir/10" ]; then
        notify-send -u critical -a "Battery" "Battery low: $capacity%" "Find a charger soon."
        touch "$state_dir/10"
      fi
    '';
  };
in
{
  home.packages = [ batteryNotify pkgs.libnotify ];

  systemd.user.services.battery-notify = {
    Unit = {
      Description = "Notify on low battery";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${batteryNotify}/bin/battery-notify";
    };
  };

  systemd.user.timers.battery-notify = {
    Unit = {
      Description = "Poll battery level for low-battery notifications";
    };
    Timer = {
      OnBootSec = "1m";
      OnUnitActiveSec = "60s";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
