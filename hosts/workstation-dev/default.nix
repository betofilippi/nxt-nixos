{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix   # GERAR no alvo com nixos-generate-config
    ./disko.nix
    ./gpu.nix
    ../../modules/common.nix
    ../../modules/nvidia.nix
    ../../modules/desktop-cosmic.nix
    ../../modules/packages.nix
  ];

  networking.hostName = "workstation-dev";

  # Bootloader — UEFI + systemd-boot (Secure Boot DESLIGADO na BIOS; decisão do usuário).
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Cofre (SSD-B, disco de dados) — só reconectar/declarar APÓS o install base ──
  # Está com nofail: o boot não trava se o disco estiver desconectado (Fase 0).
  fileSystems."/var/mnt/modelos" = {
    device = "/dev/disk/by-uuid/ab7a243a-e346-415e-a3d5-1933ab3b5c4e";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };

  # Home Manager integrado ao flake.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.betofilippi = import ../../home/betofilippi.nix;

  # Usuário dev.
  users.users.betofilippi = {
    isNormalUser = true;
    description = "betofilippi";
    extraGroups = [ "wheel" "networkmanager" "video" "render" ];
    # senha definida no install (passwd) ou via hashedPasswordFile (não inline).
  };

  system.stateVersion = "25.11";   # VALIDAR: casar com a versão do canal no momento do install.
}
