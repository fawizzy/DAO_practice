import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { assert } from "console";
import hre from "hardhat";

describe("DAO", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployDAO() {
    
    // Contracts are deployed using the first signer/account by default
    const [owner, admin1, admin2, admin3] = await hre.ethers.getSigners();

    const DAO = await hre.ethers.getContractFactory("DAO");
    const dao = await DAO.deploy(admin1.address, admin2.address, admin3.address);

    return { dao, admin1, admin2, admin3 };
  }


  it("create proposal", async function(){
    const {dao } = await deployDAO()
    await dao.createProposal("title1")
    console.log(await dao.getProposalById(0));
    expect((await dao.getProposalById(0)).title).to.be.equal("title1");
  })

  it("approve count should be one", async function(){
    const {dao, admin1, admin2, admin3 } = await deployDAO()
    await dao.createProposal("title1")
    await dao.connect(admin1).vote(0, true);
    expect((await dao.getProposalById(0)).approveCount).to.be.equal(1);
  })

  it("approve count should be 2", async function(){
    const {dao, admin1, admin2, admin3 } = await deployDAO()
    await dao.createProposal("title1")
    await dao.connect(admin1).vote(0, true);
    await dao.connect(admin2).vote(0, true);
    expect((await dao.getProposalById(0)).approveCount).to.be.equal(2);
  })

  it("should revert vote if proposal have more than 1 one accepted vote", async function(){
    const {dao, admin1, admin2, admin3 } = await deployDAO()
    await dao.createProposal("title1")
    await dao.connect(admin1).vote(0, true);
    await dao.connect(admin2).vote(0, true);

    await expect((dao.connect(admin3).vote(0, true))).to.be.revertedWith("Proposal has been finalised");
  })

  it("should revert if same admin vote more than once", async function(){
    const {dao, admin1, admin2, admin3 } = await deployDAO()
    await dao.createProposal("title1")
    await dao.connect(admin1).vote(0, true);

    await expect(dao.connect(admin1).vote(0, true)).to.be.revertedWith("voted this proposal already");
  })

  it("should revert if none admin tries to vote", async function(){
    const {dao, admin1, admin2, admin3 } = await deployDAO()
    await dao.createProposal("title1")

    await expect(dao.vote(0, true)).to.be.revertedWith("only admin can vote");
  })
  



});
