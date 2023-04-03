import { expect } from "chai";
import { ethers } from "hardhat";

describe("ProxyGetImpl", function () {

  describe("Test", function () {
    it("test", async function () {
      const SimpleImpl = await ethers.getContractFactory("SimpleImpl");
      const simpleImpl = await SimpleImpl.deploy();
      const ProxyGetImpl = await ethers.getContractFactory("ProxyGetImpl");
      const proxyGetImpl = await ProxyGetImpl.deploy(simpleImpl.address);

      const simpleImplViaProxy = await SimpleImpl.attach(proxyGetImpl.address);

      let val = 7;
      await simpleImplViaProxy.set(val);
      expect(await simpleImplViaProxy.get()).to.equal(val);

      expect(await proxyGetImpl.PROXY_getImplementation()).to.equal(simpleImpl.address);
    });
  });
});
