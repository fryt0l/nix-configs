{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Prague";
  i18n.defaultLocale = "en_US.UTF-8";

  # Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = { layout = "cz"; variant = ""; };
  console.keyMap = "cz-lat2";
  services.flatpak.enable = true;

  # Sound and Printing
  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User Account
  users.users.fry = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ kdePackages.kate ];
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # --- RUNESCAPE / BOLT LAUNCHER FIXES ---
  nixpkgs.config.allowUnfree = true;

  # Allow the specific legacy OpenSSL version required by the game
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];


  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    # Re-adding Firefox and your other essential tools
    pkgs.flatpak
    pkgs.brave
    mangohud
    keepassxc
    kdePackages.kate
    linuxKernel.packages.linux_xanmod_stable.nvidia_x11
    pkgs.steam-run
    #xivlauncher-rb
    pkgs.fastfetch
    pkgs.gamemode
    pkgs.discord
    pkgs.vlc
    pkgs.lutris-free

   # This creates a "standard Linux" environment for Bolt
    (pkgs.buildFHSEnv {
      name = "bolt-launcher";
      # targetPkgs provides 64-bit libs
      targetPkgs = pkgs: with pkgs; [
        bolt-launcher
        gtk2-x11
        openssl_1_1
        glib
        libGL
        xorg.libX11
      ];
      # multiPkgs provides 32-bit (i686) libs for the game process
      multiPkgs = pkgs: with pkgs; [
        pkgsi686Linux.gtk2-x11
        pkgsi686Linux.openssl_1_1
        pkgsi686Linux.glib
        pkgsi686Linux.libGL
        pkgsi686Linux.xorg.libX11
      ];
      runScript = "bolt-launcher";
    })
  ];
  programs.steam.enable = true;
  programs.nix-ld.enable = true;
  programs.firefox.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    gtk2-x11
    glib
    xorg.libX11
    openssl_1_1
    pkgsi686Linux.gtk2-x11
    pkgsi686Linux.openssl_1_1
  ];

  system.stateVersion = "25.11";
}
