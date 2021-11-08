
const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory("EpicNftGame");
    const gameContract = await gameContractFactory.deploy(
        ["Kung Lao", "Johnny Cage", "Sonya", "Jax", "Lui Kang", "Sub-Zero", "Scorpion", "Kitana", "Jackie-Chan", "Bruce-Lee", "Terminator"],       // Names
        [   "https://gateway.pinata.cloud/ipfs/QmbhYvHd4XsnVsub2Ya7B25EdooanYqJTY1qtCGctTejzp", // Images
            "https://gateway.pinata.cloud/ipfs/QmdosFD2RBMFiQoCvAJxSvurar4QtXg7hHE2nxDU75aRvS",
            "https://gateway.pinata.cloud/ipfs/QmU8Bom8R8a2Uq2yqGj4RzygKu7P6fCEghdL664hJDxsn3",
            "https://gateway.pinata.cloud/ipfs/QmdZ3PKZgwB2LorzGeCAf2cYC7rqzTkRTi9FyHjDE7A13q",
            "https://gateway.pinata.cloud/ipfs/QmecwcAutzBbRKBweCSYkbNvZVAKMES4GSdBGetk9KWruQ",
            "https://gateway.pinata.cloud/ipfs/QmQpQrRJ1mmP7cQa7LqgVro9Kngoo3xbrr58fN5gDZenih",
            "https://gateway.pinata.cloud/ipfs/QmYhMkQoQT9Ayv6sugc1oEsaK7L4W8vGSw4Hv1ExmJUtbD",
            "https://gateway.pinata.cloud/ipfs/Qmd2NmUzjLsxbXPSp22NEJw9BFHSmzXaxePa8vPfdKTWtW",
            "https://gateway.pinata.cloud/ipfs/Qme8DTTmv6kxx75VZedVUZsXcmt6iBKzFDXNm4amjfaD1Y",
            "https://gateway.pinata.cloud/ipfs/Qmcua8F7HY7g8g9cn3xeS2GbUCakfqynzJ4NYHc7PkLa8m",
            "https://gateway.pinata.cloud/ipfs/Qmby3yGTLrkYSgXZbxBrYfnQ4zibHnFxogff4GbNeSAYsE"
        ],
        [200, 200, 300, 400, 200, 300, 400, 200, 350, 400, 250],// HP values
        [100, 50, 50, 50, 68, 70, 100, 50, 80, 80, 50],// Attack damage values
        "ShanTsung", //Boss name
        "https://gateway.pinata.cloud/ipfs/QmZTR7pp566TP6dJnFMk6gnoRw7cLJfXYVuFcASqQEDTXo",
        10000, // Boss Hp
        50, // Boss attack damage


    );
    await gameContract.deployed();
    console.log("Contract deployed", gameContract.address)

    let tx;
     
    tx = await gameContract.mintCharacter(3);
    await tx.wait();

    tx = await gameContract.attackBoss()
    await tx.wait()

    tx = await gameContract.attackBoss()
    await tx.wait()

    // return the nft"s tokenURI

    // let returnedTokenURI = await gameContract.tokenURI(1);
    // console.log("TokenURI:", returnedTokenURI)
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (err) {
        console.log(err);
        process.exit(1);

    }
};

runMain();