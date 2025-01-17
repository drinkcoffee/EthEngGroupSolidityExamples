pub mod counter_deploy;
pub mod counter_existing;

pub use counter_deploy::CounterDeploy;
pub use counter_existing::CounterExisting;

use alloy::{
    providers::RootProvider as AlloyRootProvider,
    transports::http::{Client, Http},
};

pub type Transport = Http<Client>;
pub type RootProvider = AlloyRootProvider<Transport>;
pub use alloy::primitives::Address;
pub use alloy::providers::Provider;
pub use alloy::providers::ProviderBuilder;
pub use alloy::transports::http::reqwest::Url;
