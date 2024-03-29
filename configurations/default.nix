{pkgs, ...}: {
  imports = [./pipewire.nix];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    gc = {
      automatic = true;
      dates = "Thu";
    };
  };

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
  };

  sops = {
    gnupg = {
      home = "/var/lib/sops";
      sshKeyPaths = [];
    };

    defaultSopsFile = "/etc/sops/secrets.yaml";
    validateSopsFiles = false;
  };

  boot = {
    cleanTmpDir = true;
    plymouth.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;

    initrd.luks.devices.root.allowDiscards = true;

    loader = {
      timeout = 0;
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        editor = false;
      };
    };
  };

  fileSystems = {"/nix".options = ["defaults" "noatime"];};
  networking = {
    useDHCP = false;
    hosts = {
      "127.0.0.1" = ["modules-cdn.eac-prod.on.epicgames.com"];
    };
  };
  time.timeZone = "Europe/London";

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      tlater = {
        isNormalUser = true;
        extraGroups = ["wheel" "video"];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git # To manage the nixos configuration, all users need git
    home-manager # To manage the actual user configuration
    lightlocker # Lock screen
    pavucontrol # In case the host doesn't have audio, this can't be in the user config
  ];

  environment.extraInit = ''
    # Do not want this in the environment. NixOS always sets it and does not
    # provide any option not to, so I must unset it myself via the
    # environment.extraInit option.
    unset -v SSH_ASKPASS
  '';

  programs = {
    dconf.enable = true;
    zsh.enable = true;
  };

  fonts = {
    enableDefaultFonts = true;

    fonts = with pkgs; [hack-font noto-fonts noto-fonts-cjk noto-fonts-emoji];

    fontconfig = {
      defaultFonts = {
        serif = ["NotoSerif"];
        sansSerif = ["NotoSans"];
        monospace = ["Hack"];
      };
    };
  };

  # My systems never have usable root accounts anyway, so emergency
  # mode just drops into a shell telling me it can't log into root
  systemd.enableEmergencyMode = false;

  services = {
    xserver = {
      enable = true;
      layout = "us";
      libinput = {
        enable = true;
        mouse.middleEmulation = false;
      };

      displayManager = {
        lightdm = {
          enable = true;
          extraConfig = ''
            # Create .Xauthority in /var/run/user instead of $HOME
            user-authority-in-system-dir = true
          '';
        };
        session = [
          # This session doesn't do anything, but lightdm will fail to
          # start a session if we don't have at least one set
          {
            manage = "desktop";
            name = "default";
            start = "";
          }
        ];
      };
    };

    udev.packages = with pkgs; [yubikey-personalization];

    chrony.enable = true;
    pcscd.enable = true;
    flatpak.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # Necessary for opening links in gnome under certain conditions
  services.gvfs.enable = true;

  system.stateVersion = "20.09";
}
