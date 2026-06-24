{
  # ════════════════════════════════════════════════════════════════════════
  #  Particionamento declarativo do DISCO DE SISTEMA (será APAGADO).
  #  Fixado por SERIAL — os dois SSDs são o MESMO modelo, /dev/nvmeXn1 é instável.
  #  ⚠️ ESTE é o único disco que o disko toca. O cofre (serial 2P482LAJ99HF) deve
  #     estar FISICAMENTE DESCONECTADO durante o install (Fase 0).
  # ════════════════════════════════════════════════════════════════════════
  disko.devices.disk.system = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-ADATA_LEGEND_960_2P332L1SHAXC";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          label = "NIXOS-ESP";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" "-L" "NIXOS-ROOT" ];
            subvolumes = {
              "@"        = { mountpoint = "/";        mountOptions = [ "compress=zstd" "noatime" ]; };
              "@home"    = { mountpoint = "/home";    mountOptions = [ "compress=zstd" "noatime" ]; };
              "@nix"     = { mountpoint = "/nix";     mountOptions = [ "compress=zstd" "noatime" ]; };
              "@persist" = { mountpoint = "/persist"; mountOptions = [ "compress=zstd" "noatime" ]; };
            };
          };
        };
      };
    };
  };
  # Swap = zramSwap (modules/common.nix). Se builds CUDA derem OOM, adicionar swapfile
  # btrfs (nodatacow) pós-install — ver RUNBOOK. (Evitado aqui p/ não fragilizar o disko.)
}
