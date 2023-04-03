solc --strict-assembly contracts/TransparentProxy.yul --optimize --bin

# solc contracts/Proxy.sol --bin --asm --no-cbor-metadata --optimize --optimize-runs=1000
solc contracts/Proxy.sol --bin-runtime --no-cbor-metadata --optimize --optimize-runs=1000
# solc contracts/Proxy.sol --bin --no-cbor-metadata --optimize --optimize-runs=1000

solc contracts/Jump.sol --bin-runtime --no-cbor-metadata

solc contracts/ProxyGetImpl.sol  --no-cbor-metadata --optimize --optimize-runs=1000  --hashes --gas --ir
solc --strict-assembly contracts/ProxyGetImplYul.yul --optimize --bin --optimize-runs=1000
