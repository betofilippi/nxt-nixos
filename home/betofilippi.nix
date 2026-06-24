{ pkgs, ... }:
{
  home.stateVersion = "25.11";   # VALIDAR: casar com o canal no install.

  programs.bash.enable = true;
  programs.git.enable = true;

  # Dotfiles reais (bashrc/gitconfig/kitty/starship…) são RESTAURADOS do
  # _maquina/shell pós-install. Aqui fica só o mínimo declarativo + ganchos.

  # ── COSMIC config (RON) — best-effort, NÃO totalmente declarável ──
  # O app de Settings reescreve ~/.config/cosmic/ em RON; versionar só o ESTÁVEL
  # (ex.: keybinds). Formato pode mudar entre releases de COSMIC (beta).
  # xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".source =
  #   ./cosmic/shortcuts.ron;   # exemplo; popular após estabilizar a config no alvo.

  home.packages = with pkgs; [ ];
}
