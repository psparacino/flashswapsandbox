const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");

const ERC20ABI = require("@uniswap/v2-core/build/ERC20.json").abi;

describe ("Flash Swap", function() {
    const USDCHolder = "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE";
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const borrowAmount = 1000000000; // since USDC is 6 decimals, this corresponds to 1000 USDC Coins

    before (async() => {
        const TestFlashSwapFactory = await ethers.getContractFactory('flashSwap');
        TestFlashSwapContract = await TestFlashSwapFactory.deploy();
        await TestFlashSwapContract.deployed();
        console.log("hitting")
    })

    it("flash swap test", async () => {
        await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [USDCHolder],
        });
        const impersonateSigner = await ethers.getSigner(USDCHolder);

        const USDCContract= new ethers.Contract(USDCAddress, ERC20ABI, impersonateSigner);

        const fee = Math.round(((borrowAmount * 3)/997)) + 1;

        await USDCContract.connect(impersonateSigner).transfer(TestFlashSwapContract.address, fee);

        await TestFlashSwapContract.testFlashSwap(USDCContract.address, borrowAmount);

        const TestFlashSwapContractBalance = await USDCContract.balanceOf(TestFlashSwapContract.address);

        expect(TestFlashSwapContractBalance.eq(BigNumber.from("0"))).to.be.true;

    })


})