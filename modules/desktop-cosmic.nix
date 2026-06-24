{ ... }:
{
  # COSMIC (System76) — nativo no nixpkgs + flake nixos-cosmic (cache cosmic.cachix.org).
  # Requisito-alvo: workspaces independentes por monitor + tiling.
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # ⚠️ CHECKPOINT (a) — GATE antes de migrar o trabalho diário:
  #   provar na geração de teste que workspaces per-monitor + tiling fazem o que
  #   o usuário precisa (risco conhecido: cosmic-comp #697). Se falhar → rollback
  #   de geração + reavaliar (NOTA: KDE Plasma 6.7 faz per-monitor nativo).
  #
  # Config interna do COSMIC (~/.config/cosmic, RON) NÃO é declarável pelo módulo;
  # versionada best-effort via Home Manager (home/betofilippi.nix).
}
