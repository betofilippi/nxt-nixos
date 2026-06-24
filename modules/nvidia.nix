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

  # ── GSP firmware ──
  # ⚠️ CORRIGIDO (onboarding 2026-06-24): `NVreg_EnableGpuFirmware=0` só vale no driver
  #   PROPRIETÁRIO. A Blackwell EXIGE módulos OPEN, e o open REQUER GSP firmware → NÃO dá
  #   pra desligar (a flag é no-op/ignorada no open). O hang tipo #1111 do RTX PRO 6000 é
  #   mitigado por VERSÃO de driver/kernel, não por desligar GSP.
  #   (VALIDAR no alvo; ver recursos/nixos-nvidia-cuda no cofre.)

  # ── Seleção da GPU de display no COSMIC ──
  # ⚠️ CORRIGIDO (onboarding 2026-06-24): cosmic-comp é **Smithay**, NÃO wlroots → IGNORA
  #   `WLR_DRM_DEVICES`/`COSMIC_RENDER_DEVICE`. O display sai na GPU onde os MONITORES estão
  #   FISICAMENTE ligados (a 3050); a Blackwell (sem monitor) fica livre p/ CUDA — sem pinar via env.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
  # VALIDAR no alvo: confirmar que o COSMIC renderiza/scanout na 3050 e a Blackwell aparece
  #   só no nvidia-smi/CUDA. Ver recursos/cosmic/docs/nvidia-dual-gpu.md no cofre.

  # CUDA disponível no sistema (a Blackwell é o device de compute).
  # Habilitar conforme uso; sem o cache binário certo, compila local (ver flake.nix nixConfig).
  # nixpkgs.config.cudaSupport = true;   # ligar quando o cache CUDA estiver validado
}
