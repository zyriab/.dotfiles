{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.initrd.kernelModules = [ "virtio_gpu" ];
  boot.kernelParams = [ "console=tty" ];
  boot.tmp.cleanOnBoot = true;

  zramSwap.enable = true;

  networking.hostName = "germain";
  networking.domain = "";

  time.timeZone = "Europe/Brussels";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAShO/JDmlKC2RAVURPnSUpc+EQrj2/C2PrKeHbChkte lab@x1"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKkD8JFtguKfrnNtNHDuF0KG69Fx1iUKYjLkmdYqjqVk root@xenia"
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.root = import ./home.nix;
  };

  environment.systemPackages = with pkgs; [
    neovim
    btop
    git
    curl
    ripgrep
    lazygit
  ];

  system.stateVersion = "25.11";
}
