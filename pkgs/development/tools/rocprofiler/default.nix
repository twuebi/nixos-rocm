{stdenv, fetchFromGitHub, cmake, rocr, roct, roctracer, hcc-unwrapped, python}:
let pyenv = python.withPackages (ps: [ps.sqlite3dbm]); in
stdenv.mkDerivation rec {
  name = "rocprofiler";
  version = "2.10.0";
  src = fetchFromGitHub {
    owner = "ROCm-Developer-Tools";
    repo = "rocprofiler";
    rev = "roc-${version}";
    sha256 = "0s2nhjdgl64lav9fd416wfgzwd8vwhl1lhsn8pwq0mnx8pmkrihy";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [ rocr roct pyenv ];
  propagatedBuildInputs = [ roctracer ];
  patchPhase = ''
    patchShebangs test/run.sh
    patchShebangs bin
    sed 's|#!/usr/bin/python|#!${pyenv}/bin/python|' -i bin/dform.py
    sed 's|/usr/bin/clang++|clang++|' -i cmake_modules/env.cmake
    sed -e 's|/bin/ls|ls|' \
        -e 's|\([[:space:]]\)python\([[:space:]]\)|\1${pyenv}/bin/python\2|g' \
        -e 's|$ROCTRACER_PATH|${roctracer}/roctracer|g' \
        -e 's|$HCC_HOME|${hcc-unwrapped}|g' \
        -i bin/rpl_run.sh
  '';
}
