//! Using a pre-existing contract

use std::str::FromStr;

use alloy::{
    network::EthereumWallet,
    primitives::{Address, U256},
    providers::ProviderBuilder,
    signers::local::LocalSigner,
    transports::http::reqwest::Url,
};
use serde::Deserialize;

#[macro_use]
extern crate load_file;

use counter::CounterExisting;
use tracing::info;

#[derive(Deserialize)]
struct Config {
    keystore_path: String,
    pw_path: String,
}

#[tokio::main]
async fn main() -> eyre::Result<()> {
    tracing_subscriber::fmt::init();

    // Read the args.
    let args: Vec<_> = std::env::args().collect();
    let contract_address = args
        .get(1)
        .ok_or(eyre::eyre!("No contract address provided"))?;

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
        .on_http(Url::parse("https://rpc.testnet.immutable.com")?);

    // Connect to the existing contract.
    info!("Connecting to contract at: {contract_address}");
    let contract_address = Address::from_str(contract_address)?;
    let contract = CounterExisting::new(contract_address, provider).await?;

    // Listen for events asynchronously.
    info!("Listening for events");
    let event_contract = contract.clone();
    tokio::spawn(async move {
        while let Ok(event) = event_contract.wait_for_event().await {
            info!("Event found: Number changed: {}", event._val);
        }
    });
    // Set the number to trigger an event.
    info!("Calling Counter::set_number(100)");
    contract.set_number(U256::from(100u64)).await?;

    // Use the contract.
    info!("Calling Counter::number()");
    let number = contract.number().await?;
    info!("Number read: {}", number);

    info!("Calling Counter::increment()");
    let txhash = contract.increment().await?;
    info!("Increment tx hash: {}", txhash);

    // Get expected error.
    info!("Calling Counter::set_number(existing)");
    let number = contract.number().await?;
    if let Err(err) = contract.set_number(number).await {
        info!("Expected Error: {err:#?}");
    }

    Ok(())
}
