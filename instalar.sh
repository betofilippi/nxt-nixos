#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════
#  instalar.sh — instalação NixOS workstation-dev em UM comando.
#  RODE NO INSTALADOR NixOS (live USB), na raiz do repo clonado:
#      git clone https://github.com/betofilippi/nxt-nixos && cd nxt-nixos
#      sudo bash instalar.sh
#  Faz: guard (cofre READ-ONLY) → confirma → disko → hardware-config →
#       auto-seleção do driver NVIDIA → nixos-install.
#  Único input seu: digitar APAGAR (confirma o wipe) e a senha do root.
# ════════════════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
NIX="nix --extra-experimental-features nix-command --extra-experimental-features flakes"

# ── 0. trava de segurança: estamos MESMO no instalador NixOS? ──
command -v nixos-install >/dev/null 2>&1 || {
  echo "ERRO: 'nixos-install' não existe aqui — isto SÓ roda no INSTALADOR NixOS (live USB),"
  echo "      nunca no sistema atual. ABORTADO (nada foi tocado)."; exit 1; }
[ "$(id -u)" = "0" ] || { echo "Rode com sudo:  sudo bash instalar.sh"; exit 1; }

echo "════════ NXT — instalação NixOS workstation-dev ════════"

# ── 1. GUARD anti-wipe (identifica por serial, trava o cofre READ-ONLY) ──
echo; echo "### 1 — guard anti-wipe (trava o cofre)"
bash scripts/guard-disks.sh

# ── confirmação humana antes do passo destrutivo ──
echo
echo ">>> O PRÓXIMO PASSO APAGA o disco de SISTEMA (serial 2P332L1SHAXC, 1,9T)."
echo ">>> O COFRE (2P482LAJ99HF, 3,7T) está READ-ONLY e NÃO será tocado."
read -rp ">>> Digite exatamente  APAGAR  para prosseguir (qualquer outra coisa aborta): " ans
[ "$ans" = "APAGAR" ] || { echo "Abortado pelo usuário — nada foi apagado."; exit 1; }

# ── 2. disko: particiona/formata/monta SÓ o disco de sistema (by-id) ──
echo; echo "### 2 — disko"
$NIX run github:nix-community/disko/latest -- --mode destroy,format,mount ./hosts/workstation-dev/disko.nix

# ── 3. hardware-configuration.nix (SEM fileSystems — o disko os fornece) ──
echo; echo "### 3 — hardware-configuration.nix"
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/workstation-dev/hardware-configuration.nix
echo "ok -> hosts/workstation-dev/hardware-configuration.nix"

# ── 4. driver NVIDIA: auto-escolher a branch mais nova ≥580 (Blackwell) ──
echo; echo "### 4 — selecionando driver NVIDIA (≥580.65 p/ Blackwell)"
declare -A V
for b in production beta latest; do
  V[$b]=$($NIX eval --raw "nixpkgs#linuxPackages.nvidiaPackages.$b.version" 2>/dev/null || echo 0)
  echo "  nvidiaPackages.$b = ${V[$b]}"
done
best=$(for b in production beta latest; do echo "${V[$b]} $b"; done | sort -V | tail -1 | awk '{print $2}')
if [ "${V[$best]%%.*}" -ge 580 ] 2>/dev/null; then
  sed -i "s|nvidiaPackages\.[a-zA-Z_]*;|nvidiaPackages.$best;|" modules/nvidia.nix
  echo ">>> escolhido: nvidiaPackages.$best (${V[$best]}) — aplicado em modules/nvidia.nix"
else
  echo ">>> AVISO: a mais nova é ${V[$best]} (<580). Blackwell pode não subir."
  echo ">>>        Edite modules/nvidia.nix manualmente se souber a branch certa."
  read -rp ">>> Enter p/ continuar mesmo assim, Ctrl-C p/ parar: " _
fi

# ── 5. instalar (pede a senha do root) ──
echo; echo "### 5 — nixos-install (vai pedir a senha do root)"
git config --global --add safe.directory "$PWD" 2>/dev/null || true
git add -A 2>/dev/null || true   # o flake precisa enxergar o hardware-config + nvidia.nix patchados
nixos-install --flake .#workstation-dev

echo
echo "════════ CONCLUÍDO ════════"
echo ">>> Reboot quando quiser (retire o USB)."
echo ">>> Depois: checkpoints (a)-(d) → cofre volta RW sozinho → restore do _maquina (RUNBOOK Fase 3)."
echo ">>> E volte o repo a privado:  gh repo edit betofilippi/nxt-nixos --visibility private"
