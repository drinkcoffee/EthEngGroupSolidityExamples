// Using a pre-existing contract

use alloy::{
    network::EthereumWallet, providers::ProviderBuilder,
    signers::local::LocalSigner, transports::http::reqwest::Url,
};
use eyre::Result;

#[macro_use]
extern crate load_file;


use counter_existing::CounterExisting;
use counter_deploy::CounterDeploy;


#[tokio::main]
async fn main() -> Result<()> {
    // Read the configuration.
    let config = toml::from_str::<Config>(load_str!("../../config.toml"))?;

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

    let contract = CounterDeploy::new(provider, 42).await?;
    let contract_address = contract.address().await?;
    println!("Deployed to: {}", contract_address);

    let number = contract.number().await?;
    println!("Number initial value: {}", number);

    let txhash = contract.increment().await?;
    println!("Increment tx hash: {}", txhash);
    let number = contract.number().await?;
    println!("Number after increment: {}", number);


    let existing = CounterExisting::new(contract_address, provider).await?;
    let contract_address2 = contract.address().await?;
    println!("Using existing at: {}", contract_address2);

    let number = existing.number().await?;
    println!("Number read via existing: {}", number);

    let txhash = existing.increment().await?;
    println!("Increment tx hash: {}", txhash);

    let number = existing.number().await?;
    println!("Number read via existing: {}", number);

    let number = contract.number().await?;
    println!("Number read via deploy: {}", number);

    Ok(())
}
