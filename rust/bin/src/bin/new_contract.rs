// Deploy a new contract.

use alloy::primitives::U256;
use alloy::{
    network::EthereumWallet, providers::ProviderBuilder, signers::local::LocalSigner,
    transports::http::reqwest::Url,
};
use eyre::Result;
use serde::Deserialize;

#[macro_use]
extern crate load_file;

use counter::CounterDeploy;

#[derive(Deserialize)]
struct Config {
    keystore_path: String,
    pw_path: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    // Read the configuration.
    let config = toml::from_str::<Config>(load_str!("../../../config.toml"))?;

    // Create the wallet.
    let pw = load_str!(config.pw_path.as_str()).trim();
    let signer = LocalSigner::decrypt_keystore(config.keystore_path, pw)?;
    let wallet = EthereumWallet::new(signer);

    // Create RPC provider.
    let provider = ProviderBuilder::new()
        .with_recommended_fillers()
        .wallet(wallet)
        .on_http(Url::parse("https://rpc.testnet.immutable.com")?);

    let contract = CounterDeploy::new(provider, U256::from(42u64)).await?;
    let contract_address = contract.address().await?;
    println!("Deployed to: {}", contract_address);

    let number = contract.number().await?;
    println!("Number initial value: {}", number);

    let txhash = contract.increment().await?;
    println!("Increment tx hash: {}", txhash);
    let number = contract.number().await?;
    println!("Number after increment: {}", number);

    Ok(())
}
