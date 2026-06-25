{ ... }:
{
  # ════════════════════════════════════════════════════════════════════════
  #  Backup automático declarativo (restic) — fecha o gap "zero backup"
  #  que mordeu a casa em 2026-06-24. Doc completa: recursos/backup-restic-nixos no cofre.
  #
  #  ⚠️ PÓS-INSTALL: descomentar e apontar os SECRETS (passwordFile + rclone.conf) via
  #     sops-nix/agenix OU materializados do @gsm/berglas em /run/secrets. NUNCA inline.
  #     Deixado COMENTADO p/ o `nixos-install` passar sem os secrets existirem ainda.
  # ════════════════════════════════════════════════════════════════════════

  # services.restic.backups.cofre = {
  #   initialize = true;
  #   repository = "rclone:dropbox:nxt-restic";          # off-site (Dropbox/Netcup)
  #   passwordFile = "/run/secrets/restic-cofre";        # via sops-nix/agenix
  #   rcloneConfigFile = "/run/secrets/rclone.conf";
  #   paths = [ "/var/mnt/modelos/nxt-repositorio" "/var/mnt/modelos/_maquina" ];
  #   exclude = [ "/var/mnt/modelos/nxt-repositorio/modelos-locais" ];  # 742G regeneráveis
  #   timerConfig = { OnCalendar = "daily"; Persistent = true; RandomizedDelaySec = "1h"; };
  #   pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
  # };
}
