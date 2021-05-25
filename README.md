# Setting up the demo environment
## Download the sample
- Download ZIP repository, or
- Clone the github repository
## Download and uncompress the database connection wallet file
- Uncompress in your favourite place
- Recommended: Create a wallet folder in the project root and uncompress there (wallet/ is already in .gitignore file)
## Create your enviroment configuration file
- Edit the `scripts/.env_sample` file, and set
  - TNS_SERVICE as the name of your database service
  - ADMIN_PASSWORD with the password of your DBA.
  - Optional: ADMIN_USER with the name of your SYSDBA is different of ADMIN
  - Optional: TNS_ADMIN with the location of your wallet (if you decided to user your favourite folder)
  - Optional, not recommended: User and Paswords for the dev and pre users
- Rename the file to `.env``
  `mv ./scripts/.env_sample ./scripts/.env``
## Generate environments
- Execute the initialization script
  `./scripts/initialize.sh`
