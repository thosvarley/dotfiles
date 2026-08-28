{ ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    settings = {
      mainBar = {
        "layer" = "top";
        "height" = 36;
        "margin-top" = 4;
        "margin-left" = 4;
        "margin-right" = 4;
        "spacing" = 0;
        "modules-left" = [ "niri/workspaces" ];
        "modules-center" = [ "wlr/taskbar" ];
        "modules-right" = [ "cpu" "memory" "pulseaudio" "bluetooth" "backlight" "tray" "network" "battery" "clock" ];
        "niri/workspaces" = {
          "format" = "{icon}";
          "on-click" = "activate";
        };
        "wlr/taskbar" = {
          "format" = "{icon}";
          "tooltip-format" = "{title} | {app_id}";
          "sort-by-app-id" = true;
          "on-click" = "activate";
          "on-click-middle" = "close";
          "on-click-right" = "fullscreen";
          "active-only" = false;
          "all-outputs" = false;
        };
        "tray" = {
          "spacing" = 10;
        };
        "clock" = {
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          "format" = "{:%e %B %H:%M}";
        };
        "cpu" = {
		"format" = "{usage}% ";
          "tooltip" = false;
        };
        "memory" = {
		"format" = "{}% ";
        };
        "backlight" = {
          "format" = "{percent}% {icon}";
	  "format-icons" = [ "" "" "" "" "" "" "" "" "" ];
        };
        "battery" = {
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
	  "format" = "{capacity}% {icon}";
	  "format-charging" = "{capacity}% ";
	  "format-plugged" = "{capacity}% ";
	  "format-alt" = "{time} {icon}";
	  "format-icons" = [ "" "" "" "" "" ];
        };
	"network" = {
            "format-wifi" = "";
            "format-ethernet" = "";
            "tooltip-format" = "{ifname} via {gwaddr} ";
            "format-linked" = "";
            "format-disconnected" = "⚠";
            "format-alt" = "{ifname}: {ipaddr}/{cidr}";
            "on-click" = "nm-connection-editor";
          };
	            "pulseaudio" = {
            "format" = "{volume}% {icon}";
            "format-bluetooth" = "{volume}% {icon}";
            "format-bluetooth-muted" = " {icon}";
            "format-muted" = "";
            "format-source" = "{volume}% ";
            "format-source-muted" = "";
            "format-icons" = {
              "headphone" = "";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [ "" "" "" ];
            };
          "on-click" = "pavucontrol";
        };
        "bluetooth" = {
          "format" = "";
          "format-disabled" = "";
          "format-off" = "";
          "format-connected" = " {device_alias}";
          "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
          "tooltip-format" = "{controller_alias}\t{controller_address}";
          "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
          "on-click" = "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on";
          "on-click-right" = "blueman-manager";
        };
      };
    };

    style = ''
      window#waybar * {
          font-family: Cantarell, 'Font Awesome 7 Free Solid', 'Font Awesome 7 Free';
          font-feature-settings: "tnum";
      }
      window#waybar {
          border-radius: 50px;
      }
      #bluetooth.off,
      #bluetooth.disabled { opacity: 0.5; }
      #clock { font-weight: bold; }
    '';
  };
}
