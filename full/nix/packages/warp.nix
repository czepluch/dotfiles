# Warp Terminal AppImage package
{ lib, stdenv, fetchurl, appimageTools, makeWrapper, libGL, libX11, libXext, libXi, libXtst, libxkbcommon, wayland }:

let
  pname = "warp-terminal";
  version = "0.2024.10.29.08.02.stable_02";

  src = fetchurl {
    url = "https://releases.warp.dev/linux/v${version}/warp-terminal-v${version}-1-x86_64.AppImage";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update with actual hash
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    libGL
    libX11
    libXext
    libXi
    libXtst
    libxkbcommon
    wayland
    vulkan-loader
    mesa
  ];

  extraInstallCommands = ''
    # Install desktop file
    mkdir -p $out/share/applications
    cp ${appimageContents}/dev.warp.Warp.desktop $out/share/applications/warp.desktop

    # Install icon
    mkdir -p $out/share/pixmaps
    cp ${appimageContents}/warp.png $out/share/pixmaps/

    # Fix desktop file
    substituteInPlace $out/share/applications/warp.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}' \
      --replace 'Name=Warp' 'Name=Warp Terminal'

    # Create symlink for easier access
    ln -s $out/bin/${pname} $out/bin/warp
  '';

  meta = with lib; {
    description = "The terminal for the 21st century";
    longDescription = ''
      Warp is a modern, Rust-based terminal with AI built in so you and your team can build great software, faster.
    '';
    homepage = "https://www.warp.dev/";
    downloadPage = "https://www.warp.dev/download";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
