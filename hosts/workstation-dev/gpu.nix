{ ... }:
{
  # ════════════════════════════════════════════════════════════════════════
  #  Identidade das GPUs desta máquina (host-específico). A config FUNCIONAL
  #  do NVIDIA (open, GSP-off, persistenced, pinagem de display) está em
  #  modules/nvidia.nix (comum). Aqui só documentamos os bus IDs reais.
  #
  #  Display : RTX 3050 6GB (GA107)              PCI 81:00.0  → busId PCI:129:0:0
  #  Compute : RTX PRO 6000 Blackwell (GB202GL)  PCI c1:00.0  → busId PCI:193:0:0
  #
  #  NÃO é PRIME híbrido (não há iGPU) → NÃO usamos hardware.nvidia.prime
  #  (ignorado em Wayland). O compositor é fixado na 3050 via WLR_DRM_DEVICES
  #  (modules/nvidia.nix); a Blackwell fica visível ao nvidia-smi/CUDA, sem display.
  #  Ambos os módulos do kernel carregam por padrão → nvidia-smi vê AS DUAS.
  # ════════════════════════════════════════════════════════════════════════
}
