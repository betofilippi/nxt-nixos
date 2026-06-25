# RUNBOOK — instalação NixOS workstation-dev (passo a passo, à prova de erro de disco)

> Este runbook é **auto-suficiente**: dá pra seguir SEM Claude. Os identificadores são REAIS
> (medidos 2026-06-24). NUNCA use `/dev/sdX`/`/dev/nvmeXn1` p/ decidir alvo — use SERIAL/UUID.

## STATUS (handoff 2026-06-24 — preparado com o dev fora)
**PRONTO** (não-destrutivo): backup cifrado 57G no cofre + Dropbox (Fase -1), flake+runbook no GitHub
(`github.com/betofilippi/nxt-nixos`) + cofre, ~25 recursos em `/var/mnt/modelos/nxt-repositorio/recursos/`,
ISO NixOS verificada (`/var/mnt/modelos/nixos-iso/`), `_maquina` (restore) completo, transcripts no cofre.
**◀ VOCÊ ESTÁ AQUI** → Fase 0 (FÍSICO, exige você presente) → Fase 1 (install, guiado ao vivo).
**Nada destrutivo foi/será feito sem você presente + o cofre fisicamente desconectado.**

## Identificadores (decorar a diferença)
- **APAGAR** (vira NixOS): `/dev/disk/by-id/nvme-ADATA_LEGEND_960_2P332L1SHAXC` (1,9T, ESP do Fedora).
- **PRESERVAR** (cofre): serial `2P482LAJ99HF` · UUID `ab7a243a-e346-415e-a3d5-1933ab3b5c4e` · `LABEL=modelos`.

---
## Fase -1 — Backup (GATE) ✅ feito nesta sessão
- Blob cifrado de 57G dividido em **9 partes** `cofre.NN.part` (`_backup-stage/parts/`) no cofre + **Dropbox** (`dropbox:nxt-cofre-backup/parts/`). (Subido em paralelo p/ velocidade.)
- **Chave privada** p/ decifrar: `/var/mnt/modelos/_backup-stage/backup-ssh-ed25519` (também temporariamente em `dropbox:nxt-TEMP-apagar-key/` — **excluir definitivamente** após salvar offline) → **SALVAR OFFLINE** (sem ela o backup é lixo).
- Restore: baixar as partes e `cat parts/cofre.*.part | age -d -i <chave> | tar -xf -`.

## Fase 0 — Segurança física (responsabilidade do usuário)
1. Confirmar o backup acima (e a chave salva offline).
2. **Desligar a máquina e DESPLUGAR o cabo do cofre** (serial `2P482LAJ99HF`). Conferir o serial antes de desconectar.
3. Na BIOS: **Secure Boot = OFF**. Confirmar boot UEFI.
4. (Opcional) retirar o pendrive USB `sda`.

## Fase 1 — Instalar
1. Boot no **USB do instalador NixOS unstable**. Rede OK (`ping github.com`).
2. `sudo -i` ; `nix-env -iA nixos.git` (ou já vem). **`git clone https://github.com/betofilippi/nxt-nixos`** ; `cd nxt-nixos`.
   (Repo está PÚBLICO p/ o install — clone anônimo, sem login. **Voltar pra privado depois:** `gh repo edit betofilippi/nxt-nixos --visibility private`.)
3. **Conferir o alvo do disko**: `ls -l /dev/disk/by-id/ | grep 2P332L1SHAXC` (tem que existir e ser o disco de sistema). O cofre (`2P482...`) NÃO deve aparecer (está desconectado).
4. **Particionar+formatar (DESTRUTIVO, só o disco de sistema)**:
   `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./hosts/workstation-dev/disko.nix`
5. **Gerar hardware-configuration.nix**:
   `sudo nixos-generate-config --no-filesystems --root /mnt`
   → copiar `/mnt/etc/nixos/hardware-configuration.nix` para `./hosts/workstation-dev/hardware-configuration.nix`.
6. **VALIDAR antes de cravar** (prompt §5 — não assumir):
   - Driver: `nix repl` → `:lf nixpkgs` → `:p legacyPackages.x86_64-linux.linuxPackages.nvidiaPackages.{production,beta,latest}.version` → escolher ≥580.65 c/ Blackwell; ajustar `package` em `modules/nvidia.nix`.
   - Cache CUDA: conferir substituter+chave atuais (github.com/SomeoneSerge/nixpkgs-cuda-ci) e ajustar `flake.nix`.
   - Kernel ↔ módulo open compatível.
7. `sudo nixos-install --flake .#workstation-dev` ; definir senha do `betofilippi` ; **reboot**.

## Fase 2 — Checkpoints (GATE antes de migrar o trabalho)
- **(a)** Login COSMIC sobe na 3050, 3 monitores, **workspaces per-monitor + tiling** OK ← se falhar, parar e reavaliar (rollback de geração disponível).
- **(b)** `nvidia-smi` vê AS DUAS (3050 + Blackwell 96GB).
- **(c)** Teste CUDA mínimo na Blackwell (ex.: `nix shell nixpkgs#cudaPackages.saxpy` ou um tensor).
- **(d)** `sudo nixos-rebuild switch --flake .#workstation-dev` reaplica limpo + geração anterior aparece no boot.

## Fase 3 — Reconectar cofre + restaurar
1. Desligar, **replugar o cofre** (serial `2P482LAJ99HF`).
2. Boot. O mount `/var/mnt/modelos` (UUID, `nofail`) sobe sozinho (já no `default.nix`). `df -h /var/mnt/modelos`.
3. **Claude Code**: `npm i -g @anthropic-ai/claude-code` (sob nix-ld). Restaurar auth/config/memória:
   `cp -a /var/mnt/modelos/_maquina/claude-config/* ~/.claude/` (CLAUDE.md/settings/rules/memory).
   Restaurar `claude-accounts.json` de `_maquina/config-nxt`. Abrir sessão NOVA → lê a memória + transcripts (`_maquina/claude-sessions`).
4. Restaurar o resto sob demanda do `_maquina` (ver `_maquina/host-os/REINSTALL.md`): dotfiles, perfis (Chrome/Karere), gcloud, DBs (containers/dumps), units systemd, /etc.
5. **Commitar o flake** (com o hardware-configuration.nix gerado) no repo. A base está versionada desde o dia 1.

## Recuperação
- Sistema novo quebrou? **Rollback de geração** no menu do systemd-boot.
- Disco/instalação corrompida? Rebootar o **USB de fallback** e refazer da Fase 1.
- Tudo perdido? O cofre (intacto) + o Dropbox cifrado têm os dados; este runbook + o flake (GitHub) reconstroem o sistema.
