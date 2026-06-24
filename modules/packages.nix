{ pkgs, ... }:
{
  # Pacotes base + dev. Toolchains pesadas (rust/go/etc.) preferencialmente por projeto
  # (devShells/direnv) ou restauradas via mise do _maquina — não inchar o sistema.
  environment.systemPackages = with pkgs; [
    # CLI base
    gh ripgrep fd bat fzf jq yq-go btop du-dust eza zoxide direnv
    git-lfs gnumake unzip p7zip tree file
    # runtime p/ Claude Code (binário dynamically-linked → nix-ld cobre; ver common.nix)
    nodejs_22
    # GPU/diagnóstico
    nvtopPackages.nvidia pciutils
  ];

  # ── Claude Code ──
  # Caminho recomendado: `npm i -g @anthropic-ai/claude-code` rodando sob nix-ld
  # (programs.nix-ld.enable em common.nix) + nodejs_22 acima.
  # ⚠️ VALIDAR-NO-ALVO: se o binário FHS não subir com nix-ld, usar um flake mantido
  #   de claude-code (conferir qual está vivo) OU patchelf. Restaurar auth/config do
  #   _maquina (claude-config + claude-accounts.json).

  programs.direnv.enable = true;
}
