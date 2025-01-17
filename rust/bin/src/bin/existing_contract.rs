// Using a pre-existing contract

use alloy::primitives::U256;
use alloy::providers::ReqwestProvider;
use alloy::{
    network::EthereumWallet, providers::ProviderBuilder, signers::local::LocalSigner,
    transports::http::reqwest::Url,
};
use eyre::Result;
use serde::Deserialize;

#[macro_use]
extern crate load_file;

use counter::CounterDeploy;
use counter::CounterExisting;

#[derive(Deserialize)]
struct Config {
    keystore_path: String,
    pw_path: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    // Read the configuration.
    let config = toml::from_str::<Conflg>(load_str!("../../../config.toml"))?;

    // Create the wallet.
    let pw = load_str!(config.pw_path.as_str()).trim();
    let signer = LocalSigner::decrypt_keystore(config.keystore_path, pw)?;
    let wallet = EthereumWallet::new(signer);

    // Create RPC provider.
    let provider = ProviderBuilder::new()
        .with_recommended_fillers()
        .wallet(wallet)
        .on_http(Url::parse("https://rpc.testnet.immutable.com")?);

    let val = 42;

    let contract = CounterExisting::new(*contract_address, provider).await?;
    let contract_address2 = contract.address().await?;
    println!("Using existing at: {}", contract_address2);

    let number = contract.number().await?;
    println!("Number read via existing: {}", number);

    let txhash = contract.increment().await?;
    println!("Increment tx hash: {}", txhash);

    let number = contract.number().await?;
    println!("Number read via existing: {}", number);

    let number = contract.number().await?;
    println!("Number read via deploy: {}", number);

    Ok(())
}
