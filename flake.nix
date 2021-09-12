{
  description = "Apache Milagro Crypto Library";

  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.amcl = {
    url = "github:apache/incubator-milagro-crypto-c";
    flake = false;
  };

  outputs = { self, nixpkgs, amcl, ... }: {

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
    let
      usePython = false;
      buildBLS = true;
      buildWCC = false;
      buildMPIN = false;
      buildX509 = false;
      buildShareLib = true;
      curves = "bls_BLS381,SECP256K1";
      chunk = "64";
      rsa = "";
      cFlags = "-fPIC";
      buildType = "Release";
      installPrefix = "/usr/local";
      cmakeFlags = [
          "-DCMAKE_BUILD_TYPE=${buildType}"
          "-DAMCL_CHUNK=${chunk}"
          "-DBUILD_SHARED_LIBS=${if buildShareLib then "ON" else "OFF"}"
          "-DBUILD_PYTHON=${if usePython then "ON" else "OFF"}"
          "-DBUILD_BLS=${if buildBLS then "ON" else "OFF"}"
          "-DBUILD_WCC=${if buildWCC then "ON" else "OFF"}"
          "-DBUILD_MPIN=${if buildMPIN then "ON" else "OFF"}"
          "-DBUILD_X509=${if buildX509 then "ON" else "OFF"}"
          "-DCMAKE_INSTALL_PREFIX=${installPrefix}"
          "-DAMCL_CURVE=${curves}"
          "-DAMCL_RSA=${rsa}"
          "-DCMAKE_C_FLAGS=${cFlags}"
      ];
    in
      stdenv.mkDerivation {
        name = "apache-milagro-crypto-c-library";
        src = amcl;

        buildInputs = [ cmake doxygen ];

        installPhase = ''
          mkdir -p $out/build && cd $out/build
          cp -r $src/. $out
          cmake ${toString cmakeFlags} ..
          export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:\.
          make
          make doc
          make install
        '';
      };
    };
}
