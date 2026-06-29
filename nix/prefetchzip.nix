{
  stdenv,
  bash,
  coreutils,
  findutils,
  gnugrep,
  nix,
}:
stdenv.mkDerivation rec {
  pname = "prefetchzip";
  version = "1.0.0";

  dontUnpack = true;

  installPhase = ''
        mkdir -p "$out/bin"
        cat > "$out/bin/${pname}" <<EOF
    #!${bash}/bin/bash
    set -uo pipefail

    HASH=\$( ${nix}/bin/nix-build -E "with import <nixpkgs> {}; fetchzip {url = \"\$1\"; sha256 = \"\"; }" \
      2> >(tail -n 1) \
      | ${gnugrep}/bin/grep -oE "sha256-.{40,}" \
      | ${findutils}/bin/xargs )
    if [ -z "\$HASH" ]; then
      SHA=\$( ${nix}/bin/nix-prefetch-url --unpack "\$1" )
      HASH=\$( nix hash to-sri --type sha256 "\$SHA" )
    fi
    echo "\$HASH"
    exit 0
    EOF
        chmod +x "$out/bin/${pname}"
  '';
}
