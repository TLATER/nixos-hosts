{ config, pkgs, ... }:

{
  imports =
    [
      ./modules

      ./hardware-configuration.nix
      ./secrets.nix
      ./vpns

      # TODO: make these actual options instead of commenting them out
      ./haruna.nix
    ];

  boot = {
    cleanTmpDir = true;
    plymouth.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;

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

  networking = {
    hostName = "haruna";
    wireless.enable = true;

    useDHCP = false;
    interfaces = {
      eno1.useDHCP = true;
      enp10s0.useDHCP = true;
      wlp8s0.useDHCP = true;
    };
  };

  time.timeZone = "Europe/London";

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      tlater = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" "video" "libvirtd" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git           # To manage the nixos configuration, all users need git
    home-manager  # To manage the actual user configuration
    fuse3         # Fuse can't be installed as a user application
    lightlocker   # Lock screen
    pavucontrol   # In case the host doesn't use pulseaudio, this can't be in the user config
  ];

  programs = {
    dconf.enable = true;
    light.enable = true;
    zsh.enable = true;
  };

  fonts = {
    enableDefaultFonts = true;

    fonts = with pkgs; [
      hack-font
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "NotoSerif" ];
        sansSerif = [ "NotoSans" ];
        monospace = [ "Hack" ];
      };
    };
  };

  sound.enable = true;

  services = {
    xserver = {
      enable = true;
      layout = "us";
      libinput.enable = true;

      displayManager = {
        lightdm.enable = true;
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

    udev.packages = with pkgs; [
      yubikey-personalization
    ];

    pcscd.enable = true;
    flatpak.enable = true;
    blueman.enable = true;
    fstrim.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    gtkUsePortal = true;
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  system = {
    stateVersion = "19.09";
    autoUpgrade = {
      enable = true;
      dates = "weekly";
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  hardware = {
    bluetooth = {
      enable = true;
    };
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    cpu.intel = {
      updateMicrocode = true;
    };
  };
}
