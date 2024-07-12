const SatoshiChain = artifacts.require("SatoshiChain");

contract("SatoshiChain", accounts => {
  it("should allow the creation and verification of plots", async () => {
    const contract = await SatoshiChain.deployed();
    await contract.createPlot(1000, "test_proof", { from: accounts[0] });
    const plot = await contract.plots(accounts[0]);
    assert.equal(plot.size, 1000);
  });

  it("should allow the creation of blocks after the time interval", async () => {
    const contract = await SatoshiChain.deployed();
    const canGenerateBlock = await contract.canGenerateBlock.call();
    assert.equal(canGenerateBlock, true);

    await contract.createBlock("test_challenge", { from: accounts[0] });
    const block = await contract.getBlock(0);
    assert.equal(block.miner, accounts[0]);
  });

  it("should allow the creation of proposals and voting", async () => {
    const contract = await SatoshiChain.deployed();
    await contract.createProposal("New proposal", { from: accounts[0] });
    await contract.vote(1, { from: accounts[1] });
    const proposal = await contract.proposals(1);
    assert.equal(proposal.voteCount, 1);
  });
});
