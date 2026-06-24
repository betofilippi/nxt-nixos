# nxt-nixos — workstation-dev (NixOS unstable + COSMIC + dual-GPU)

Base declarativa/reproduzível da workstation de desenvolvimento NXT. Princípio: **se não está no flake, não existe**.

## Hardware-alvo (medido 2026-06-24)
- **Display**: RTX 3050 6GB (GA107) — PCI `81:00.0` · busId `PCI:129:0:0` · DRM `/dev/dri/by-path/pci-0000:81:00.0`.
- **Compute**: RTX PRO 6000 Blackwell (GB202GL, 96GB) — PCI `c1:00.0` · busId `PCI:193:0:0` · headless CUDA.
- **Disco sistema** (apagar): ADATA LEGEND 960 serial `2P332L1SHAXC` → `/dev/disk/by-id/nvme-ADATA_LEGEND_960_2P332L1SHAXC`.
- **Cofre** (preservar): ADATA LEGEND 960 serial `2P482LAJ99HF` · ext4 `LABEL=modelos` · UUID `ab7a243a-e346-415e-a3d5-1933ab3b5c4e`.

## ⚠️ LISTA "VALIDAR-NO-ALVO" (nunca cravar de memória — prompt §5/§8)
1. **Branch+versão do driver NVIDIA** (`production`/`beta`/`latest`) ≥580 c/ suporte Blackwell GB202 — `nix repl`:
   `:lf nixpkgs` → `:p legacyPackages.x86_64-linux.linuxPackages.nvidiaPackages.{production,beta,latest}.version`. Escolher ≥580.65.
2. **Cache CUDA**: substituter + chave atuais (`cache.nixos-cuda.org`?) contra SomeoneSerge/nixpkgs-cuda-ci.
3. **Kernel**: confirmar compat do módulo NVIDIA open com o kernel escolhido (não usar `_latest` cego).
4. **Env de seleção de GPU** (`WLR_DRM_DEVICES`/`COSMIC_RENDER_DEVICE`): confirmar nomes/efeito no COSMIC do alvo.
5. **Claude Code**: nix-ld+nodejs vs flake mantido — ver qual está vivo no alvo.
6. **`hardware-configuration.nix`**: gerar com `nixos-generate-config` (NÃO está versionado aqui).

## Estrutura
```
flake.nix                          inputs, caches, output workstation-dev
hosts/workstation-dev/
  default.nix                      importa módulos + host
  hardware-configuration.nix       (GERAR no alvo)
  disko.nix                        btrfs @/@home/@nix/@persist + ESP, disco por serial
  gpu.nix                          bus IDs 3050(display)/Blackwell(compute)
modules/
  common.nix                       nix settings, flakes, gc, locale, ssh, zram
  nvidia.nix                       open modules, GSP-off, persistenced, display-pin, allowUnfree
  desktop-cosmic.nix               COSMIC + greeter
  packages.nix                     base + dev + nix-ld + claude-code
home/betofilippi.nix               Home Manager (dotfiles + COSMIC RON best-effort)
```

## Instalar (resumo — runbook completo em RUNBOOK-NIXOS.md)
0. **Cofre fisicamente desconectado** (serial `2P482LAJ99HF`) + backup confirmado.
1. Boot instalador NixOS unstable. `git clone <este repo>`.
2. `sudo nix run github:nix-community/disko -- --mode disko ./hosts/workstation-dev/disko.nix`
3. `nixos-generate-config --no-filesystems --root /mnt` → copiar `hardware-configuration.nix`.
4. Validar a lista acima (driver/cache/kernel). `nixos-install --flake .#workstation-dev`.
5. Reboot → checkpoints (a)-(d). Reconectar cofre. Restaurar de `/var/mnt/modelos/_maquina`.

Segredos NUNCA entram aqui (vão por `@gsm`/berglas em runtime, ou restaurados do `_maquina`).
