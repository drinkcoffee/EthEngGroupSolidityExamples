import { expect } from "chai";
import { ethers } from "hardhat";

describe("ProxyGetImplYul", function () {

  describe("Test", function () {
    it("test", async function () {
      const SimpleImpl = await ethers.getContractFactory("SimpleImpl");
      const simpleImpl = await SimpleImpl.deploy();


      const fs = require('fs');
      const proxyGetImplJson = JSON.parse(fs.readFileSync('./artifacts/contracts/ProxyGetImpl.sol/ProxyGetImpl.json', 'utf8'));
      const proxyGetImplYulJson = JSON.parse(fs.readFileSync('./artifacts/contracts/ProxyGetImplYul.yul/ProxyGetImplYul.json', 'utf8'));
      const ProxyGetImplYul = await ethers.getContractFactory(proxyGetImplJson.abi, proxyGetImplYulJson.bytecode);
      const proxyGetImplYul = await ProxyGetImplYul.deploy(simpleImpl.address);

      const simpleImplViaProxy = await SimpleImpl.attach(proxyGetImplYul.address);

      let val = 7;
      await simpleImplViaProxy.set(val);
      expect(await simpleImplViaProxy.get()).to.equal(val);

      expect(await proxyGetImplYul.PROXY_getImplementation()).to.equal(simpleImpl.address);
    });
  });
});
