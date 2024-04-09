{
  description = "Acconeer Python Exploration Tool";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    packageOverrides = let
      all = pkgs.callPackage ./python-packages.nix { };
    in self: super:
    #builtins.removeAttrs (all self super) ["pyperclip"];
    { inherit (all self super) pyqtdarktheme sphinxext-rediraffe textual; };
    python3 = pkgs.python3.override { inherit packageOverrides; };
  in {
    devShells.x86_64-linux.default = let
      python = python3.withPackages (p: with p; [
        attrs
        cbor2
        numpy
        pandas
        packaging
        pyserial
        pyusb
        pyyaml
        requests
        typing-extensions
        textual
        xlsxwriter
        exceptiongroup
        h5py

        beautifulsoup4
        docutils
        matplotlib
        platformdirs
        psutil
        pyperclip
        pyside6
        pyqtdarktheme
        pyqtgraph
        qtawesome
        qtpy
        scipy
        myst-parser
        scipy
        sphinx
        sphinx-design
        pydata-sphinx-theme
        sphinxext-rediraffe
        sphinx-notfound-page

        pip
      ]);
    in
    pkgs.mkShell {
      packages = [
        python
      ];

      shellHook = ''
        [ -d venv ] || python -m venv venv --system-site-packages
        source venv/bin/activate
        export PYTHONHOME=${python}

        echo "Maybe run this:"
        echo "  python -m pip install -e .[app]"
        echo "  python -m acconeer.exptool.app"
      '';
    };
  };
}
