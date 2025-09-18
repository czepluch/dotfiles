# Cursor AI Editor AppImage package
{ lib, stdenv, fetchurl, appimageTools, makeWrapper, electron }:

let
  pname = "cursor";
  version = "0.42.2";

  src = fetchurl {
    url = "https://downloader.cursor.sh/linux/appImage/x64";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update with actual hash
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Install desktop file
    mkdir -p $out/share/applications
    cp ${appimageContents}/cursor.desktop $out/share/applications/

    # Install icon
    mkdir -p $out/share/pixmaps
    cp ${appimageContents}/cursor.png $out/share/pixmaps/

    # Fix desktop file
    substituteInPlace $out/share/applications/cursor.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'

    # Create wrapper script
    makeWrapper $out/bin/${pname} $out/bin/cursor \
      --add-flags "--no-sandbox"
  '';

  meta = with lib; {
    description = "The AI-first code editor";
    homepage = "https://cursor.so/";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
