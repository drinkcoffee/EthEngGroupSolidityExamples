import { expect } from "chai";
import { ethers } from "hardhat";

describe("ProxyGetImplBin", function () {

  describe("Test", function () {
    it("test", async function () {
      const SimpleImpl = await ethers.getContractFactory("SimpleImpl");
      const simpleImpl = await SimpleImpl.deploy();

      const byteCode = "0x6054600f3d396034805130553df3fe63906111273d3560e01c14602b57363d3d373d3d3d3d369030545af43d82803e156027573d90f35b3d90fd5b30543d5260203df3";

      const fs = require('fs');
      const proxyGetImplJson = JSON.parse(fs.readFileSync('./artifacts/contracts/ProxyGetImpl.sol/ProxyGetImpl.json', 'utf8'));
//      const proxyGetImplBinJson = JSON.parse(fs.readFileSync('./artifacts/contracts/ProxyGetImplBin.yul/ProxyGetImplBin.json', 'utf8'));
      const ProxyGetImplBin = await ethers.getContractFactory(proxyGetImplJson.abi, byteCode);
      const proxyGetImplBin = await ProxyGetImplBin.deploy(simpleImpl.address);

      const simpleImplViaProxy = await SimpleImpl.attach(proxyGetImplBin.address);

      let val = 7;
      await simpleImplViaProxy.set(val);
      expect(await simpleImplViaProxy.get()).to.equal(val);

      expect(await proxyGetImplBin.PROXY_getImplementation()).to.equal(simpleImpl.address);
    });
  });
});
