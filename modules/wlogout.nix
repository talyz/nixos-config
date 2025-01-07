{
  pkgs,
  config,
  ...
}:
let
  user = config.talyz.username;
in
{
  home-manager.users.${user} = { lib, config, ... }:
  let
    bgImageSection = name: ''
      #${name} {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/${name}.png"));
      }
    '';
  in
    {
      programs.wlogout = {
        enable = true;

        # layout = [
        #   {
        #     label = "shutdown";
        #     action = "systemctl poweroff";
        #     text = "Power off";
        #     keybind = "p";
        #   }
        #   {
        #     label = "suspend";
        #     action = "systemctl suspend";
        #     text = "Suspend";
        #     keybind = "s";
        #   }
        #   {
        #     label = "hibernate";
        #     action = "systemctl hibernate";
        #     text = "Hibernate";
        #     keybind = "h";
        #   }
        #   {
        #     label = "lock";
        #     action = "loginctl lock-session";
        #     text = "Lock screen";
        #     keybind = "l";
        #   }
        # ];

        style = ''
          * {
            background: none;
          }

          window {
            background: transparent;
          }

          button {
            background: rgba(0, 0, 0, 0.6);
            box-shadow:
              inset 0 0 0 1px rgba(255, 255, 255, 0.1),
              0 30px 30px 15px rgba(0, 0, 0, 0.49);
            border-radius: 8px;
            margin: 1rem;
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
          }

          button:focus, button:active, button:hover {
            background-color: rgba(63, 63, 63, 0.6);
            outline-style: none;
          }

          ${lib.concatMapStringsSep "\n" bgImageSection [
            "lock"
            "logout"
            "suspend"
            "hibernate"
            "shutdown"
            "reboot"
          ]}
        '';
      };
    };
}
