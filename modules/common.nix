{ pkgs, ... }:
{
  # ── Nix: flakes + cache + GC + store enxuto ──
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # 'wheel' confiável p/ usar os substituters extras do flake (caches CUDA/cosmic).
    trusted-users = [ "root" "@wheel" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Userspace NVIDIA é proprietário → unfree obrigatório (CUDA, driver).
  nixpkgs.config.allowUnfree = true;

  # ── Swap p/ builds pesados do Nix (CUDA pode dar OOM) ──
  # zram primeiro (rápido); o swapfile-disco vem do subvolume @swap no disko.nix.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # nix-ld: rede de segurança p/ binários dynamically-linked (Claude Code/Node) fora de container.
  programs.nix-ld.enable = true;

  # ── Rede / acesso remoto do PRÓPRIO dev (NÃO de usuários finais) ──
  networking.networkmanager.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;   # só chave; defina authorizedKeys no host/home.
  };
  # GANCHO (fase futura): pipeline de deploy dev → Netcup entra aqui. Não implementar agora.
  # ex.: programs.ssh.extraConfig p/ o host de produção; deploy-rs/colmena; secrets via sops-nix.

  # IOMMU já vem ligado por hardware; manter (medido: iommu=pt no Fedora).
  boot.kernelParams = [ "iommu=pt" ];

  # ── Locale / timezone / teclado (= config REAL medida: US-International) ──
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  console.keyMap = "us";   # TTY: teclado físico us-intl → "us" cobre os símbolos (acento dead-key só no gráfico)
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
    model = "microsoftpro";
    options = "terminate:ctrl_alt_bksp";
  };

  environment.systemPackages = with pkgs; [ git vim wget curl rsync age ];
}
