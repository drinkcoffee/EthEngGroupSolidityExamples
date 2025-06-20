//! Generating a Keystore File

use std::fs::read_to_string;

use alloy::{hex, signers::local::LocalSigner};
use rand::thread_rng;
use tempfile::tempdir;
use tracing::info;

#[tokio::main]
async fn main() -> eyre::Result<()> {
    tracing_subscriber::fmt::init();

    // Create a temporary directory to store the keystore file.
    let dir = tempdir()?;
    let mut rng = thread_rng();

    // Get the private key to encode.
    let private_key =
        std::env::var("PRIVATE_KEY").map_err(|_| eyre::eyre!("env var PRIVATE_KEY not set"))?;
    let private_key = hex::decode_to_array::<_, 32>(private_key)?;

    // Get password to encrypt the keystore file with.
    let password =
        std::env::var("PASSWORD").map_err(|_| eyre::eyre!("env var PASSWORD not set"))?;

    // Create a keystore file from the private key of Alice, returning a [Wallet] instance.
    let (wallet, file_path) =
        LocalSigner::encrypt_keystore(&dir, &mut rng, private_key, password.clone(), None)?;

    let keystore_file_path = dir.path().join(file_path);
    info!(
        "Wrote keystore for {} to {:?}",
        wallet.address(),
        keystore_file_path
    );

    // Read the keystore file back.
    let recovered_wallet = LocalSigner::decrypt_keystore(keystore_file_path.clone(), password)?;

    info!(
        "Read keystore from {:?}, recovered address: {}",
        keystore_file_path,
        recovered_wallet.address()
    );

    // Assert that the address of the original key and the recovered key are the same.
    if wallet.address() != recovered_wallet.address() {
        eyre::bail!("Addresses do not match");
    }

    // Display the contents of the keystore file.
    let keystore_contents = read_to_string(keystore_file_path)?;
    info!("Keystore file contents: {keystore_contents:?}");

    Ok(())
}
