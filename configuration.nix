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
  };

  environment.systemPackages = with pkgs; [
    quarkdb
  ];

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlVJZbI3ffSF9MaBUdzAZ4MQyDR2Xr8qZ4qI/nldl49 carlos@pepelabs.net"
  ];

  system.stateVersion = "24.11";
}
