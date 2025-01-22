//! Deploy a new contract

use alloy::primitives::U256;
use alloy::{
    network::EthereumWallet, providers::ProviderBuilder, signers::local::LocalSigner,
    transports::http::reqwest::Url,
};
use serde::Deserialize;

#[macro_use]
extern crate load_file;

use counter::CounterDeploy;
use tracing::info;

#[derive(Deserialize)]
struct Config {
    keystore_path: String,
    pw_path: String,
}

#[tokio::main]
async fn main() -> eyre::Result<()> {
    tracing_subscriber::fmt::init();

    // Read the configuration.
    info!("Reading configuration");
    let config = toml::from_str::<Config>(load_str!("../../../config.toml"))?;

    // Create the wallet.
    let pw = load_str!(config.pw_path.as_str()).trim();
    let signer = LocalSigner::decrypt_keystore(config.keystore_path, pw)?;
    let wallet = EthereumWallet::new(signer);

    // Create RPC provider.
    let url = Url::parse("https://rpc.testnet.immutable.com")?;
    info!("Creating RPC provider for: {url}");
    let provider = ProviderBuilder::new()
        .with_recommended_fillers()
        .wallet(wallet)
        .on_http(url);

    // Deploy the contract.
    info!("Deploying Counter contract");
    let contract = CounterDeploy::new(provider, U256::from(42u64)).await?;
    let contract_address = contract.address().await?;
    info!("Deployed to: {contract_address}");

    // Use the contract.
    info!("Calling Counter::number()");
    let number = contract.number().await?;
    info!("Number initial value: {}", number);

    info!("Calling Counter::increment()");
    let txhash = contract.increment().await?;
    info!("Increment tx hash: {}", txhash);

    info!("Calling Counter::number()");
    let number = contract.number().await?;
    info!("Number after increment: {}", number);

    Ok(())
}
