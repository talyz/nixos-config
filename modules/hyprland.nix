{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.talyz.hyprland;
  user = config.talyz.username;
in
  {
    options = {

      talyz.hyprland = {

        enable = mkOption {
          default = false;
          example = true;
          description = "Whether to enable the hyprland window manager.";
          type = types.bool;
        };

      };

    };

    config = mkIf cfg.enable {

      talyz.common-graphical.enable = true;
      talyz.anyrun.enable = true;

      programs.hyprland.enable = true;

      programs.light.enable = true;

      # programs.nm-applet.enable = true;

      # programs.gnupg.agent.enable = true;
      # programs.gnupg.agent.enableSSHSupport = true;

      # Install fonts needed for waybar
      fonts.packages = [ pkgs.font-awesome ];

      environment.systemPackages = with pkgs; [
        grimblast
      ];

      # Enable PAM settings for hyprlock to work.
      security.pam.services.hyprlock = {
        # hyprlock doesn't handle fingerprint auth well
        fprintAuth = false;
      };

      home-manager.users.${user} = { lib, ... }:
      {
        # services.dunst.enable = true;
        # services.dunst.iconTheme = {
        #   package = pkgs.gnome3.adwaita-icon-theme;
        #   name = "Adwaita";
        # };
        # services.dunst.settings =  {
        #   global = {
        #     geometry = "500x5-30+50";
        #     padding = 8;
        #     horizontal_padding = 8;
        #     frame_color = "#eceff1";
        #     font = "Droid Sans 11";
        #   };

        #   urgency_normal = {
        #     background = "#37474f";
        #     foreground = "#eceff1";
        #     timeout = 10;
        #   };
        # };
        programs.ags.enable = true;
        services.network-manager-applet.enable = true;

        services.udiskie.enable = true;
        systemd.user.services.udiskie.Service.Environment = [
          "DE=gnome" # Always be gnome to xdg-open
        ];

        wayland.windowManager.hyprland =
          let
            toggle = program:
              let
                prog = head (splitString " " program);
              in
              "pkill ${prog} || systemd-run --user --property=ExitType=cgroup -E XDG_BACKEND=wayland -E XDG_SESSION_TYPE=wayland ${program}";
          in
          {
          enable = true;
          plugins = with pkgs.hyprlandPlugins; [
            hy3
          ];
          settings = {
            "$mod" = "SUPER";

            # Binds for mouse things
            bindm = [
              # Move/resize windows with mod + LMB/RMB and dragging
              "$mod, mouse:272, movewindow"
              "$mod, mouse:273, resizewindow"
            ];

            # Repeatable keybinds that works on the lock screen
            bindel = [
              # Audio:
              ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"
              ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+"

              # Backlight:
              ", XF86MonBrightnessUp, exec, light -A 10"
              ", XF86MonBrightnessDown, exec, light -U 10"
            ];

            bind =
              [
                "$mod, Return, exec, foot"
                "$mod, e, exec, fish -c emacs"

                # Logout menu
                "$mod, Escape, exec, ${toggle "wlogout"} -p layer-shell"

                # Lock screen
                "$mod, L, exec, loginctl lock-session"

                ",     Print, exec, grimblast copy area"
                "$mod, Print, exec, grimblast save area"

                "$mod, q, hy3:killactive,"
                ",     F11, fullscreen,"

                # "$mod, G, togglegroup,"
                # "ALT, TAB, changegroupactive, f"
                # "ALT SHIFT, TAB, changegroupactive, b"
                # "$mod, r, togglesplit,"

                "$mod, f, togglefloating,"
                "$mod, p, pseudo,"
                "$mod ALT, ,resizeactive,"

                # move focus
                "$mod, h, hy3:movefocus, l, visible"
                "$mod, n, hy3:movefocus, r, visible"
                "$mod, c, hy3:movefocus, u, visible"
                "$mod, t, hy3:movefocus, d, visible"
                "$mod CTRL, h, focusmonitor, l"
                "$mod CTRL, n, focusmonitor, r"
                "$mod CTRL, c, focusmonitor, u"
                "$mod CTRL, t, focusmonitor, d"
                "$mod, g, hy3:focustab, l, wrap"
                "$mod, r, hy3:focustab, r, wrap"

                # move window
                "$mod SHIFT, h, hy3:movewindow, l, visible"
                "$mod SHIFT, n, hy3:movewindow, r, visible"
                "$mod SHIFT, c, hy3:movewindow, u, visible"
                "$mod SHIFT, t, hy3:movewindow, d, visible"
                "$mod SHIFT CTRL, h, hy3:movewindow, l"
                "$mod SHIFT CTRL, n, hy3:movewindow, r"
                "$mod SHIFT CTRL, c, hy3:movewindow, u"
                "$mod SHIFT CTRL, t, hy3:movewindow, d"
                "$mod SHIFT, g, hy3:movewindow, l"
                "$mod SHIFT, r, hy3:movewindow, r"

                # Hy3 specific keybinds, from etu
                "$mod,       s,      hy3:makegroup, v, ephemeral" # Make a vertical split
                "$mod SHIFT, s,      hy3:makegroup, h, ephemeral" # Make a horizontal split
                "$mod,       comma,  hy3:makegroup, tab" # Make a tabbed layout
                "$mod,       period, hy3:changegroup, toggletab" # Toggle between tabbad and untabbed
                "$mod,       o,      hy3:changegroup, opposite" # Change between horizontal and vertical layout
                "$mod,       u,      hy3:changefocus, raise" # Change focus to parent node
                "$mod,       d,      hy3:changefocus, lower" # Change focus to child node
                "$mod,       minus,  hy3:expand, expand" # Make the current node expand over other nodes
                "$mod SHIFT, minus,  hy3:expand, base" # Undo all expansions

                # Hacky way to move incorrectly assigned workspaces to the correct monitor
                "$mod, f1, moveworkspacetomonitor, 1 desc:CMT GP27-FUS 0000000000001"
                "$mod, f1, moveworkspacetomonitor, 2 desc:CMT GP27-FUS 0000000000001"
                "$mod, f1, moveworkspacetomonitor, 4 desc:CMT GP27-FUS 0000000000001"
                "$mod, f1, moveworkspacetomonitor, 5 desc:CMT GP27-FUS 0000000000001"
                "$mod, f1, moveworkspacetomonitor, 6 desc:CMT GP27-FUS 0000000000001"
                "$mod, f1, moveworkspacetomonitor, 7 desc:CMT GP27-FUS 0000000000001"
                "$mod, f1, moveworkspacetomonitor, 8 desc:CMT GP27-FUS 0000000000001"
                "$mod, f1, moveworkspacetomonitor, 9 desc:CMT GP27-FUS 0000000000001"
                "$mod, f1, moveworkspacetomonitor, 10 desc:CMT GP27-FUS 0000000000001"
              ]
            ++ (
              # workspaces
              # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
              builtins.concatLists (builtins.genList (
                x:
                  let
                    ws =
                      let
                        c = (x + 1) / 10;
                      in
                        builtins.toString (x + 1 - (c * 10));
                    in [
                      "$mod, ${ws}, workspace, ${toString (x + 1)}"
                      "$mod SHIFT, ${ws}, hy3:movetoworkspace, ${toString (x + 1)}, follow"
                      "$mod SHIFT, ${ws}, workspace, ${toString (x + 1)}"
                    ]
              )
                10)
            );
            bindr = [
              # launcher
              # "$mod, SUPER_L, exec, wofi --show drun"
              "$mod, SUPER_L, exec, ${toggle "anyrun"}"
            ];

            exec-once = [
              "hyprctl setcursor Adwaita 24"
              # "${pkgs.mako}/bin/mako"
            ];

            layerrule = [
              "ignorealpha 0.5, ^(anyrun)$"
              "blur, ^(anyrun)$"
              "ignorealpha 0.5, ^(logout_dialog)$"
              "blur, ^(logout_dialog)$"
            ];

            general = {
              layout = "hy3";

              gaps_in = 5;
              gaps_out = 5;
              border_size = 1;
              "col.active_border" = "rgba(88888888)";
              "col.inactive_border" = "rgba(00000088)";

              allow_tearing = false;
              resize_on_border = true;
            };

            gestures = {
              workspace_swipe = true;
              workspace_swipe_create_new = false;
            };

            # plugin.hyprexpo = {
            #   workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1
            #   enable_gesture = true; # laptop touchpad
            #   gesture_fingers = 3;  # 3 or 4
            #   gesture_distance = 300; # how far is the "max"
            #   gesture_positive = false; # positive = swipe down. Negative = swipe up.
            # };

            plugin.hy3 = {
              tab_first_window = true;
            };

            workspace = [
              "1,  monitor:desc:CMT GP27-FUS 0000000000001"
              "2,  monitor:desc:CMT GP27-FUS 0000000000001"
              "3,  monitor:eDP-1"
              "4,  monitor:desc:CMT GP27-FUS 0000000000001"
              "5,  monitor:desc:CMT GP27-FUS 0000000000001"
              "6,  monitor:desc:CMT GP27-FUS 0000000000001"
              "7,  monitor:desc:CMT GP27-FUS 0000000000001"
              "8,  monitor:desc:CMT GP27-FUS 0000000000001"
              "9,  monitor:desc:CMT GP27-FUS 0000000000001"
              "10, monitor:desc:CMT GP27-FUS 0000000000001"
            ];

            monitor = [
              "desc:CMT GP27-FUS 0000000000001,            3840x2160@144,    -320x-1440, 1.5"
              "desc:Lenovo Group Limited G27q-20 U63331YK, 2560x1440@100,    2240x-1440, 1"
              "desc:Lenovo Group Limited M14 V905RYE6,     1920x1080@60,     auto-down,  1"
              "eDP-1,                                      highrr,           0x0,        1.5"
              ",                                           preferred,        auto,       auto"
            ];

            cursor = {
              # no_warps = true;
              hide_on_key_press = true;
            };

            input = {
              kb_layout = "us";
              kb_variant = "dvorak-intl";
              kb_model = "";
              kb_options = "ctrl:nocaps";
              kb_rules = "";

              follow_mouse = true;
              emulate_discrete_scroll = 0;
              scroll_factor = 0.5;

              touchpad = {
                natural_scroll = true;
                tap-to-click = false;
                clickfinger_behavior = true;
              };

              sensitivity = 0; # -1.0 to 1.0, 0 means no modification.
            };

            device = [
              {
                name = "tpps/2-elan-trackpoint";
                accel_profile = "flat";
              }
              ] ++ (map (i: {
                name = "lenovo-trackpoint-keyboard-ii-${builtins.toString i}";
                accel_profile = "flat";
                sensitivity = 0.50;
              }) [1 2]);

            decoration = {
              rounding = 0;
              blur = {
                enabled = true;
                brightness = 1.0;
                contrast = 1.0;
                noise = 0.01;

                vibrancy = 0.2;
                vibrancy_darkness = 0.5;

                passes = 4;
                size = 7;

                popups = true;
                popups_ignorealpha = 0.2;
              };

              drop_shadow = true;
              shadow_ignore_window = true;
              shadow_offset = "0 15";
              shadow_range = 100;
              shadow_render_power = 2;
              shadow_scale = 0.97;
              "col.shadow" = "rgba(00000055)";
            };

            xwayland = {
              use_nearest_neighbor = false;
            };

            misc = {
              # disable auto polling for config file changes
              disable_autoreload = true;
            };
          };
        };

        # Enable hypridle for idle management
        services.hypridle.enable = true;
        services.hypridle.settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            before_sleep_cmd = "loginctl lock-session";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
          };

          listener = [
            {
              timeout = 1800;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 3600;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on; loginctl lock-session";
            }
          ];
        };

        # Enable hyprlock for screen locking
        programs.hyprlock.enable = true;
        programs.hyprlock.settings = {
          general = {
            disable_loading_bar = true;
            grace = 0;
            hide_cursor = true;
            no_fade_in = false;
          };
          background = [
            {
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
            }
          ];
          input-field = [
            {
              size = "200, 50";
              position = "0, -80";
              monitor = "";
              dots_center = true;
              fade_on_empty = false;
              font_color = "rgb(202, 211, 245)";
              inner_color = "rgb(91, 96, 120)";
              outer_color = "rgb(24, 25, 38)";
              outline_thickness = 5;
              placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
              shadow_passes = 2;
            }
          ];
          label = [
            {
              monitor = "";
              position = "0, 240";
              halign = "center";
              valign = "center";
              text = "$TIME";
              text_align = "center";
              color = "rgba(200, 200, 200, 1.0)";
              font_size = 96;
              font_family = "Noto Sans";
              rotate = 0;
            }
          ];
        };
      };
    };
  }
