const { time } = require('@openzeppelin/test-helpers');
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");


const ONE_TOKEN = BigNumber.from(10).pow(18);


describe("Farming200", function () {
  let farming;

  let alice;
  let dev;


  beforeEach(async function () {
    [alice, dev] = await ethers.getSigners();
  
    const Farming = await ethers.getContractFactory("Farming200", dev);

    farming = await Farming.deploy({ value : ONE_TOKEN.mul(10)});
    await farming.deployed();
  })

  it("Should be deployed", async function () {
    expect(farming.address).to.be.properAddress;
  })

  it("Check reserve", async function () {
    expect(await farming.getReserve()).to.be.eq(ONE_TOKEN.mul(10));
  })

  it("Try to pay", async function () {

    console.log("Alice pay 1 ether");
    //let alice_bal = BigNumber.from(alice.balance);
    await farming.connect(alice).makePaymentFor200Days(ONE_TOKEN.mul(1), { value : ONE_TOKEN.mul(1) });

    console.log("Reserve is 11 ethers");
    expect(await farming.getReserve()).to.be.eq(ONE_TOKEN.mul(11));

    console.log("201 days later...");
    //await time.increase(201*60*60*24);

    console.log("Alice gets a reward");
    await farming.connect(alice).getReward();

    console.log("The reserve balance has become 8");
    expect(await farming.getReserve()).to.be.eq(ONE_TOKEN.mul(8));

    console.log("The reserve balance has become 2 more than it was");
    //expect(await alice.balance).to.be.eq(BigNumber.from(alice_bal).add(ONE_TOKEN.mul(2)));

  })
}) 