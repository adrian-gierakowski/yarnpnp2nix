{ stdenv, rsync, yarn, fetchzip, nodejs }:

stdenv.mkDerivation {
  name = "yarn-berry";
  src = builtins.fetchTarball {
    url = "https://github.com/yarnpkg/berry/archive/@yarnpkg/cli/4.0.0-rc.48.tar.gz";
    sha256 = "sha256:0464rk0dlnpyk27jji6z84krjbxyald858s8d2xg3xhvmm41s5ly";
  };

  phases = [ "getSource" "patchPhase" "build" ];

  patches = [
    ./yarnPatches/pack-specific-project.patch
  ];

  buildInputs = [
    yarn
    rsync
    nodejs
  ];

  getSource = ''
    tmpDir=$PWD
    mkdir -p $tmpDir/yarn
    shopt -s dotglob
    cp --no-preserve=mode -r $src/* $tmpDir/yarn/
    cd $tmpDir/yarn
  '';

  build = ''
    yarn build:cli
    (cd packages/yarnpkg-pnp && yarn pack -o package.tgz)
    mkdir -p $out/bin $out/packages
    mv packages/yarnpkg-cli/bundles/yarn.js $out/bin/yarn
    chmod +x $out/bin/yarn
    patchShebangs $out/bin/yarn
  '';
}
