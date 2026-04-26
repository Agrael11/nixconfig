({pkgs, ...}: {
    services.displayManager.sddm = {
        enable = true;
        theme = "astronaut";
    };

    environment.systemPackages = [
        (pkgs.stdenv.mkDerivation {
            pname = "sddm-theme-astronaut";
            version = "git";

            src = pkgs.fetchFromGitHub {
                owner = "Keyitdev";
                repo = "sddm-astronaut-theme";
                rev = "master"; # you can pin a specific commit later if you want
                sha256 = "sha256-+94WVxOWfVhIEiVNWwnNBRmN+d1kbZCIF10Gjorea9M=";
            };

            installPhase = ''
            mkdir -p $out/share/sddm/themes/astronaut
            cp -r * $out/share/sddm/themes/astronaut

            # Switch default theme config to Jake the Dog
            substituteInPlace $out/share/sddm/themes/astronaut/metadata.desktop \
            --replace "ConfigFile=Themes/astronaut.conf" "ConfigFile=Themes/jake_the_dog.conf"
            '';
        })
    ];

    environment.etc."sddm.conf.d/theme.conf".text = ''
    [Theme]
    Current=astronaut
    '';

    
    environment.etc."sddm.conf.d/virtualkbd.conf".text = ''
    [General]
    InputMethod=qtvirtualkeyboard
    '';

})