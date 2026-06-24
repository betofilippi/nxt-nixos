{ ... }:
{
  # COSMIC (System76) — nativo no nixpkgs + flake nixos-cosmic (cache cosmic.cachix.org).
  # Requisito-alvo: workspaces independentes por monitor + tiling.
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # ✅ ATUALIZADO (onboarding 2026-06-24): workspaces independentes por-monitor JÁ funcionam
  #   no COSMIC via `workspace_mode = OutputBound` (DEFAULT = "displays have separate workspaces").
  #   A issue cosmic-comp #697 é OUTRA feature (i3-like "puxar workspace pra tela focada"), não
  #   o per-monitor. → o risco #1 do plano se dissolve. CHECKPOINT (a) continua como GATE apenas
  #   p/ confirmar no hardware real (3×4K + nvidia open).
  #
  # Config interna do COSMIC (~/.config/cosmic, RON) NÃO é declarável pelo módulo;
  # versionada best-effort via Home Manager (home/betofilippi.nix).
}
