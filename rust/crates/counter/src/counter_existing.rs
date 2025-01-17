//! Interact with an existing Counter contract

use alloy::{
    primitives::{Address, FixedBytes, U256},
    sol,
};

use alloy_transport::Transport;
use eyre::Result;
use futures_util::StreamExt;
use ICounter::NumberChanged;

use crate::counter_existing::ICounter::ICounterInstance;

// Counter interface: not getNumberPlus17 and number do not have defined return values.
sol! {
    // We need the bytecode for event streams.
    #[allow(missing_docs)]
    #[sol(rpc)]
    interface ICounter {
        error NoChange(uint256 _val);
        #[derive(Debug)]
        event NumberChanged(uint256 _val);

        function setNumber(uint256 _newNumber) external;
        function increment() external;
        function number() external view returns(uint256);
        function getNumberPlus17() external view returns(uint256);
        function getNumberPlus17a() external view returns(uint256 numPlus17);
    }
}

#[derive(Clone)]
pub struct CounterExisting<T, P> {
    pub token_contract: ICounterInstance<T, P>,
}

impl<T, P> CounterExisting<T, P>
where
    T: Transport + Clone,
    P: alloy_provider::Provider<T>,
{
    pub async fn new(token_address: Address, provider: P) -> Result<Self> {
        let token_contract = ICounter::new(token_address, provider);
        Ok(Self { token_contract })
    }

    pub async fn address(&self) -> Result<&Address> {
        let addr = self.token_contract.address();
        Ok(addr)
    }

    pub async fn set_number(&self, value: U256) -> Result<FixedBytes<32>> {
        let builder = self.token_contract.setNumber(U256::from(value));
        let tx_hash = builder.send().await?.watch().await?;
        Ok(tx_hash)
    }

    pub async fn increment(&self) -> Result<FixedBytes<32>> {
        let builder = self.token_contract.increment();
        let tx_hash = builder.send().await?.watch().await?;
        Ok(tx_hash)
    }

    pub async fn number(&self) -> Result<U256> {
        let builder = self.token_contract.number();
        // Note: because the artifact generated by `solc` does not include named return values it is
        // not possible to derive the return value name `number` from the artifact. This means that the
        // return value must be accessed by index - as if it is an unnamed value.
        // If you prefer to use named return values, it is recommended to embed the Solidity code
        // directly in the `sol!` macro as shown in `deploy_from_contract.rs`.
        let value = builder.call().await?._0;
        Ok(value)
    }

    pub async fn get_number_plus17(&self) -> Result<U256> {
        let res = self.token_contract.getNumberPlus17().call().await?._0;
        Ok(res)
    }

    pub async fn get_number_plus17a(&self) -> Result<U256> {
        let res = self
            .token_contract
            .getNumberPlus17a()
            .call()
            .await?
            .numPlus17;
        Ok(res)
    }

    pub async fn wait_for_event(&self) -> Result<NumberChanged> {
        let event_filter = self.token_contract.NumberChanged_filter().watch().await?;
        let mut event_stream = event_filter.into_stream();
        let a = event_stream
            .next()
            .await
            .ok_or(eyre::eyre!("Event stream provided empty event"))?;
        Ok(a?.0)
    }
}
