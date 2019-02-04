# crowdsale
A crowdsale for Blank DAO's tokens

- BlankDAO Crowdsale features a simple smart contract to sell BlankTokens in return for DAI tokens.

- At genesis point, BlankTokens are ERC-20 and their supply is limited to 21 million. Once BlankLedger is released, the tokens will be exchanged by BlankDAO native tokens one by one. 

- The supply growth of BlankTokens is similar to Bitcoin. In the first 4 years, 50 tokens are minted every 10 minutes. The number of minted BlankTokens will half every four years from then on.

- BlankTokens are initially minted and sold through the Crowdsale smart contract.

- The price starts at 0.1 DAI and rises 1% in each 10-minute interval if all previously minted tokens are sold out.

- The minting process continues no matter the previously minted tokens are sold are not. 

- In case the minted tokens are not completely sold out, remaining available tokens are saved in the Crowdsale smart contract to be sold at a fixed price, halting the 1% price rise until no more tokens are available for sale on the Crowdsale.

- At any point in time, there might be people who, for whatever reason, would like to sell their purchased tokens at a lower price than the halted price in the Crowdsale. Accordingly, there’s an exchange suggested on BlankDAO that makes it possible for holders to sell their tokens at the price of their choosing.
