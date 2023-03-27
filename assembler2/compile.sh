solc --strict-assembly contracts/TransparentProxy.yul --optimize --bin

# solc contracts/Proxy.sol --bin --asm --no-cbor-metadata --optimize --optimize-runs=1000
solc contracts/Proxy.sol --bin-runtime --no-cbor-metadata --optimize --optimize-runs=1000
# solc contracts/Proxy.sol --bin --no-cbor-metadata --optimize --optimize-runs=1000