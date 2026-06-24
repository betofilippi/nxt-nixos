{
  description = "NXT workstation-dev — NixOS unstable + COSMIC + dual NVIDIA (RTX 3050 display / RTX PRO 6000 Blackwell compute)";

  # ── Caches binários: evitam compilar COSMIC e CUDA localmente (horas de build) ──
  # ⚠️ VALIDAR-NO-ALVO: a chave do cache CUDA MUDOU em 2025 (cuda-maintainers.cachix.org
  #    → cache.nixos-cuda.org) e pode mudar de novo. Confirme substituter+chave contra
  #    github.com/SomeoneSerge/nixpkgs-cuda-ci ANTES de confiar. A chave do cosmic é estável.
  nixConfig = {
    extra-substituters = [
      "https://cosmic.cachix.org/"
      "https://cache.nixos-cuda.org"            # VALIDAR
    ];
    extra-trusted-public-keys = [
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="  # VALIDAR
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # COSMIC pelo flake da comunidade (upstreaming em andamento; cache próprio).
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Particionamento declarativo (disko) — fixa o disco por serial, não por /dev/sdX.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-cosmic, disko, ... }@inputs: {
    nixosConfigurations.workstation-dev = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        disko.nixosModules.disko
        nixos-cosmic.nixosModules.default
        home-manager.nixosModules.home-manager
        ./hosts/workstation-dev          # host-específico (hw, disko, GPU bus IDs)
      ];
    };
  };
}
