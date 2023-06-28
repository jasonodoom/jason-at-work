{ pkgs ? import (fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/4ecab3273592f27479a583fb6d975d4aba3486fe.tar.gz";
                                sha256 = "10wn0l08j9lgqcw8177nh2ljrnxdrpri7bp0g7nvrsn9rkawvlbf"; 
                              }) 
{} }:

pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (ps: [
      ps.pip
      ps.flake8
      ps.ipython
      ps.semver
      ps.virtualenv
      ps.setuptools
      ps.wheel
      ps.docopt
      ps.urllib3
      ps.mypy
      ps.semver
      ps.pyyaml
      ps.pluggy
      ps.packaging
      ps.nodeenv
      ps.more-itertools
      ps.iniconfig
      ps.contextlib2
      ps.schema
      ps.idna
      ps.identify
      ps.exceptiongroup
      ps.boto3
    ]))

    pkgs.curl
    pkgs.jq
  ];
}
