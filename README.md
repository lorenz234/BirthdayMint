# Birthday Token Mint

## Description
This project securely encrypts and stores your birthday data on the blockchain, allowing decentralized applications (dApps) to verify your age or birthday without exposing your actual birth date.


### Key Differences FHE and Zk-Proofs

- **Data Privacy:** Both FHE and Zk-Proofs enable data privacy, but in different ways. FHE ensures data remains encrypted and secure throughout computation, a kind of blanket security approach. Zk-Proofs provide only the validity of certain information, maintaining privacy in a more specific application based approach.

- **Application Use Cases:** FHE enables encrypted data to be fully stored onchain and allows (if the user permits) external contracts to compute against said private data. ZK-Proofs on the other hand, require the prover to create a satisfactory proof which the verifier can interpret. Utilizing FHE, you can shift the proving work and mathematics to the actual person who wants to verify, rather than having to do it yourself.

- **Computation & Efficiency:** FHE is more computationally intensive due to the complexity behind operations on encrypted data. ZK-Proofs are designed to be scalable, enabling faster verification times.

## Usage
1. Mint your birthday, this function stores your birthday fully encrypted onchain in the contract state
2. Mint Birthday token if today is your birthday! 

![Front End](front_end.png)

## Technologies Used
- FHE.sol
- Fhenix.js
- WalletConnect

## Contributing
This project is part of the Hackerhouse Fhenix hosted at ETH Denver 2024, thanks a lot for hosting me!

## License
MIT License
