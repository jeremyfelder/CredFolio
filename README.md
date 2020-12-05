# CredFolio
An Attested Credential Portfolio

In order to run the DApp locally, a few programs are needed:

1. Node.js/NPM - Local JS Runtime Env and Package Manager
2. Truffle Suite - Suite for easy DApp development and deployment
3. Ganache - Local ethereum blockchain for development purposes
4. MetaMask - Web3 Ethereum Wallet as a Firefox/Chrome extension 


You can download and install Node.js from https://nodejs.org/en/download/

Once Node.js and NPM are installed. Use "npm install truffle -g" to install Truffle Suite. You can view the documentation for Truffle Suite
at https://truffleframework.com/docs/truffle/overview

Next download Ganache from https://truffleframework.com/ganache 

Lastly, download the chrome or firefox extension for MetaMask from https://metamask.io/. 



Running the Program.

Setting up Ganache:

Run Ganache and check the settings in the top right corner to make sure the port is 7545

Setting up MetaMask:

Click on the MetaMask extension and "import using a seed phrase". 
Copy the Mnemonic from Ganache into MetaMask.
In the dropdown that says "Main Etherum Network" click "Custom RPC"
In the "New Network" box, enter the "RPC Server" address and port from Ganache, Click Save.
Make sure you're on the newly created network and not "Main Ethereum Network". If you are, your "Account 1" should correspond to the first address (index 0) in Ganache.
You should have multiple accounts in your MetaMask Wallet. You can check this by clicking on the colorful circle in the top right corner.
If you only have one address, import at least two more addresses by:

1. Click "Import Account"
2. In Ganache, copy a Private Key by clicking on the Key icon.
3. Paste this Private Key into MetaMask
4. Repeat for as many addresses/private keys as necessary

You can rename accounts in MetaMask for easier identification:

1. Click the three horizontal dots below the colorful circle.
2. Click "Account Details"
3. Click on the pencil icon next to the account name and then the check after changing it.

Setting up the Contract using Truffle:

Open command line/terminal and navigate to the top level of the project (master).
run "truffle compile"
run "truffle migrate --reset" (this should say defaulting to the development network)


Launching the webserver and DApp:

Run "npm run dev" (this should launch a browser window)
MetaMask should popup asking to be connected. 

Sign up as a student using one address.
In a second tab, sign up as a school using a second address.

In the school tab and using the School account, add a student by clicking on the plus icon in the top right corner.
You can copy the address of the student by switching to the student account and clicking on the account name. MAKE SURE TO SWITCH BACK
TO THE SCHOOL ACCOUNT.
Add the student by pasting the Student's address into the Student Address box and their name into the Student Name box.

Once the student is added, switch to the student account and add the School using the pencil icon in the High School section via the same method.
