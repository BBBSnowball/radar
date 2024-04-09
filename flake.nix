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
    { inherit (all self super) pyqtdarktheme sphinxext-rediraffe textual attributes-doc; };
    python3 = pkgs.python3.override { inherit packageOverrides; };
    pythonPackages = python3.pkgs;
    acconeer-python-exploration-app = pythonPackages.buildPythonApplication rec {
      pname = "acconeer-python-exploration-app";
      version = "7.9.0";

      src = pkgs.fetchFromGitHub {
        owner = "acconeer";
        repo = "acconeer-python-exploration";
        rev = "v${version}";
        hash = "sha256-hjylaqBebXdIJAyOL8w7HbIhwhz4ym79RWKb8eAvaN0=";
      };

      pyproject = true;

      postPatch = ''
        echo "[options.entry_points]" >>setup.cfg
        echo "console_scripts =" >>setup.cfg
        #echo "  acconeer-exptool-app = acconeer.exptool.app.__main__:main" >>setup.cfg  # doesn't have any function
        echo "  acconeer-exptool-app-old = acconeer.exptool.app.old:main" >>setup.cfg
        echo "  acconeer-exptool-app-new = acconeer.exptool.app.new:main" >>setup.cfg

        #echo "" >>setup.cfg
        #echo "[options.package_data]" >>setup.cfg
        #echo "\"\" = ['src/acconeer/exptool/app/resources/*.*', '*.png']" >>setup.cfg
        #echo "\"\" = ['*.png']" >>setup.cfg
        #echo "src = ['acconeer/exptool/app/resources/*.*']" >>setup.cfg

        echo "include src/acconeer/exptool/app/resources/*.*" >>MANIFEST.in
      '';

      propagatedBuildInputs = with pythonPackages; [
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
        attributes-doc

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

        setuptools
        setuptools-scm
      ];

      meta.mainProgram = "acconeer-exptool-app-new";
    };
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

    packages.x86_64-linux.acconeer-python-exploration-app = acconeer-python-exploration-app;
    apps.x86_64-linux.acconeer-python-exploration-app-new = { type = "app"; program = "${acconeer-python-exploration-app}/bin/acconeer-exptool-app-new"; };
    apps.x86_64-linux.acconeer-python-exploration-app-old = { type = "app"; program = "${acconeer-python-exploration-app}/bin/acconeer-exptool-app-old"; };
  };
}
