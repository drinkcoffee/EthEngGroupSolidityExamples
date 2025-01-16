use alloy::{
    primitives::{Address, U256},
    sol,
};

use eyre::Result;

use crate::erc20::IERC20::IERC20Instance;

use lib::prelude::*;

// ERC 20 contract specifying return value names
sol! {
    #[sol(rpc)]
    interface IERC20 {
        function totalSupply() external view returns (uint256 supply);
        function balanceOf(address account) external view returns (uint256 balance);
        function transfer(address recipient, uint256 amount) external returns (bool success);
        function allowance(address owner, address spender) external view returns (uint256 allowance);
        function approve(address spender, uint256 amount) external returns (bool success);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);

        function symbol() external view returns (string sym);
        function decimals() external view returns (uint256 value);
    }

}

pub struct Erc20 {
    pub token_contract: IERC20Instance<Transport, RootProvider>,
}

impl Erc20 {
    pub async fn new(token_address: Address, provider: RootProvider) -> Result<Self> {
        let token_contract = IERC20::new(token_address, provider);
        Ok(Self { token_contract })
    }

    pub async fn address(&self) -> Result<&Address> {
        let addr = self.token_contract.address();
        Ok(addr)
    }

    pub async fn symbol(&self) -> Result<String> {
        let tok0_symbol = self.token_contract.symbol().call().await?.sym;
        Ok(tok0_symbol)
    }

    pub async fn total_supply(&self) -> Result<U256> {
        let res = self.token_contract.totalSupply().call().await?.supply;
        Ok(res)
    }

    pub async fn decimals(&self) -> Result<U256> {
        let res = self.token_contract.decimals().call().await?.value;
        Ok(res)
    }
}
