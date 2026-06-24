{ config, pkgs, lib, ... }:
{
  # ════════════════════════════════════════════════════════════════════════
  #  NVIDIA — dual dGPU (SEM iGPU): 3050 = display/render · Blackwell = CUDA headless
  #  Decisões fechadas: módulos OPEN (Blackwell exige), Wayland/COSMIC.
  # ════════════════════════════════════════════════════════════════════════

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # OPEN modules — obrigatório p/ Blackwell; a 3050 (Ampere) também roda em open.
    open = true;

    # Wayland/COSMIC exigem modesetting.
    modesetting.enable = true;

    # Mantém a Blackwell estável servindo CUDA SEM display (headless).
    nvidiaPersistenced = true;

    nvidiaSettings = true;

    # ⚠️ VALIDAR-NO-ALVO (prompt §5): escolher branch ≥580.65 c/ suporte Blackwell GB202.
    #   nix repl → :lf nixpkgs → :p legacyPackages.x86_64-linux.linuxPackages.nvidiaPackages.{production,beta,latest}.version
    #   NÃO usar nvidiaPackages.legacy_580 (é branch legado p/ HW antigo, NÃO suporta Blackwell).
    package = config.boot.kernelPackages.nvidiaPackages.beta;   # VALIDAR: production vs beta vs latest

    # PRIME: NÃO usar. Em Wayland com 2 dGPUs, hardware.nvidia.prime é IGNORADO
    # (a GPU de render é escolhida por firmware + WLR_DRM_DEVICES). Pinagem feita abaixo.
  };

  # ── GSP firmware OFF — CRÍTICO p/ Blackwell ──
  # GB202 sofre crash/Xid sob carga sustentada de inferência com GSP ligado.
  # (Pode até estar relacionado aos freezes que vínhamos vendo.)
  boot.extraModprobeConfig = ''
    options nvidia NVreg_EnableGpuFirmware=0
  '';

  # ── Fixar a 3050 como GPU de display/render do compositor (Wayland) ──
  # 81:00.0 = RTX 3050 (display). A Blackwell (c1:00.0) fica fora do render, visível ao CUDA.
  # ⚠️ VALIDAR-NO-ALVO os nomes/efeito destas env no COSMIC do alvo.
  environment.sessionVariables = {
    WLR_DRM_DEVICES = "/dev/dri/by-path/pci-0000:81:00.0-card";
    # COSMIC-specific (confirmar no alvo):
    COSMIC_RENDER_DEVICE = "/dev/dri/by-path/pci-0000:81:00.0-card";
  };

  # CUDA disponível no sistema (a Blackwell é o device de compute).
  # Habilitar conforme uso; sem o cache binário certo, compila local (ver flake.nix nixConfig).
  # nixpkgs.config.cudaSupport = true;   # ligar quando o cache CUDA estiver validado
}
