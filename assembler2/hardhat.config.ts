import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "hardhat-gas-reporter";
import "@tovarishfin/hardhat-yul";


const config: HardhatUserConfig = {
  solidity: {
    compilers: [{ version: "0.8.19"}],
    settings: {
      optimizer: {
        enabled: true,
        runs: 999999,
        details: {
          yul: true
        }
      },
      // This might be being ignored...?
      metadata: {
        bytecodeHash: "none"
      },
    }
  },
  gasReporter: {
    enabled: true,
    //outputFile: "gas-report.txt",
    noColors: true,
  }
};

export default config;
