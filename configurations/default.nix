{ pkgs, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
  };

  sops = {
    gnupgHome = "/var/lib/sops";
    defaultSopsFile = "/etc/sops/secrets.yaml";
    sshKeyPaths = [ ];
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

  fileSystems = { "/nix".options = [ "defaults" "noatime" ]; };
  networking.useDHCP = false;
  time.timeZone = "Europe/London";

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      tlater = {
        isNormalUser = true;
        extraGroups = [ "wheel" "video" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git # To manage the nixos configuration, all users need git
    home-manager # To manage the actual user configuration
    lightlocker # Lock screen
    pavucontrol # In case the host doesn't use pulseaudio, this can't be in the user config
  ];

  programs = {
    dconf.enable = true;
    ssh.askPassword = "";
    zsh.enable = true;
  };

  fonts = {
    enableDefaultFonts = true;

    fonts = with pkgs; [ hack-font noto-fonts noto-fonts-cjk noto-fonts-emoji ];

    fontconfig = {
      defaultFonts = {
        serif = [ "NotoSerif" ];
        sansSerif = [ "NotoSans" ];
        monospace = [ "Hack" ];
      };
    };
  };

  sound.enable = true;

  # See NixOS/nixpkgs#116631
  systemd.tmpfiles.rules = [ "d /run/lightdm 0711 lightdm lightdm -" ];

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

    udev.packages = with pkgs; [ yubikey-personalization ];

    chrony.enable = true;
    pcscd.enable = true;
    flatpak.enable = true;
    blueman.enable = true;
    fstrim.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  hardware.pulseaudio.enable = true;

  system.stateVersion = "20.09";
}
