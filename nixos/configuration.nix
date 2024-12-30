{ modulesPath
, pkgs
, ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    configurationLimit = 5;
  };

  documentation.enable = true;
  documentation.dev.enable = false;
  documentation.doc.enable = false;
  documentation.info.enable = false;
  documentation.man.enable = true;
  documentation.nixos.enable = false;

  environment.ldso32 = null;

  environment.systemPackages = with pkgs; [
    quarkdb
  ];

  fonts.fontconfig.enable = false;

  hardware.enableAllFirmware = false;
  hardware.enableRedistributableFirmware = false;
  hardware.wirelessRegulatoryDatabase = false;

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  programs.command-not-found.enable = false;

  security.sudo.execWheelOnly = true;
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  services.openssh = {
    enable = true;
    settings.X11Forwarding = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PasswordAuthentication = false;
    settings.UseDns = false;
    settings.KexAlgorithms = [
      "curve25519-sha256"
      "curve25519-sha256@libssh.org"
      "diffie-hellman-group16-sha512"
      "diffie-hellman-group18-sha512"
      "sntrup761x25519-sha512@openssh.com"
    ];
  };

  time.timeZone = "UTC";

  users.mutableUsers = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlVJZbI3ffSF9MaBUdzAZ4MQyDR2Xr8qZ4qI/nldl49 carlos@pepelabs.net"
  ];

  system.stateVersion = "24.11";
}
