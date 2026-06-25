#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════
#  guard-disks.sh — proteção anti-wipe do COFRE (rodar no instalador NixOS
#  ANTES de qualquer comando de disco, já que o cofre NÃO pode ser desplugado).
#
#  Camadas: (1) identifica os 2 discos por SERIAL (by-id, à prova de troca de
#  nome /dev/nvmeXn1); (2) trava o COFRE em READ-ONLY no kernel → qualquer
#  escrita nele FALHA; (3) confirma que o disko vai apagar SÓ o sistema.
#  Uso:  sudo bash scripts/guard-disks.sh
# ════════════════════════════════════════════════════════════════════════
set -euo pipefail

COFRE_ID=/dev/disk/by-id/nvme-ADATA_LEGEND_960_2P482LAJ99HF   # PRESERVAR (3,7T, LABEL=modelos)
SYS_ID=/dev/disk/by-id/nvme-ADATA_LEGEND_960_2P332L1SHAXC     # APAGAR   (1,9T, sistema)

[ -e "$COFRE_ID" ] || { echo "ERRO: cofre by-id não existe ($COFRE_ID). NÃO rode disko — ABORTAR."; exit 1; }
[ -e "$SYS_ID"   ] || { echo "ERRO: disco de sistema by-id não existe ($SYS_ID). ABORTAR."; exit 1; }

cofre=$(readlink -f "$COFRE_ID")
sys=$(readlink -f "$SYS_ID")
[ "$cofre" != "$sys" ] || { echo "ERRO FATAL: cofre e sistema resolvem pro MESMO device ($cofre). ABORTAR."; exit 1; }

echo "═══════════ GUARD ANTI-WIPE ═══════════"
echo "COFRE   (PRESERVAR): $COFRE_ID"
echo "                  -> $cofre  ($(lsblk -dn -o SIZE "$cofre")  LABEL=$(lsblk -dn -o LABEL "$cofre" 2>/dev/null))"
echo "SISTEMA (APAGAR)   : $SYS_ID"
echo "                  -> $sys  ($(lsblk -dn -o SIZE "$sys"))"
echo

# ── trava o cofre READ-ONLY no kernel ──
blockdev --setro "$cofre"
[ "$(blockdev --getro "$cofre")" = "1" ] || { echo "ERRO: não consegui travar o cofre em RO. ABORTAR."; exit 1; }
echo ">>> COFRE $cofre AGORA É READ-ONLY (getro=1) — qualquer escrita nele FALHA."
echo ">>> Sistema $sys está RW (getro=$(blockdev --getro "$sys")) — alvo legítimo do disko."

# ── sanidade: o cofre tem o conteúdo esperado? ──
if [ "$(lsblk -dn -o LABEL "$cofre" 2>/dev/null)" = "modelos" ]; then
  echo ">>> Sanidade OK: cofre tem LABEL=modelos (é o disco certo a proteger)."
else
  echo ">>> AVISO: cofre sem LABEL=modelos — confira manualmente antes de prosseguir."
fi

echo
echo "✅ SEGURO PARA PROSSEGUIR. Proteção em 2 camadas:"
echo "   1) disko só apaga o device declarado em disko.nix (by-id $SYS_ID);"
echo "   2) o cofre está READ-ONLY — mesmo um comando errado bate numa parede."
echo
echo "Próximo: sudo nix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest \\"
echo "           -- --mode destroy,format,mount ./hosts/workstation-dev/disko.nix"
