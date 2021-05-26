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
- Rename the file to `.env`

  `mv ./scripts/.env_sample ./scripts/.env`
  
## Generate environments
- Disconnect the possible previous connection to your service
- Execute the initialization script
  `./scripts/initialize.sh`
- The script
  - will create 2 database users/schemas simulanting 2 DB environments (dev and pre). Also, will enable the EDITIONS feature for these users
  - will create a master git respository, simulating a git registry in folder `demo/environments/origin``
  - will create 2 folders to simulate 2 environments (development environment and pre-production environment)
- **WARNING**: If you use EDITIONS in your database for other tasks, notice that this script reset all EDITIONS to a new base edition called EDITION_MAIN
## Open your favourite development tools
- **Microservices testing**: Use your favorite tool for testing the microservices. If you use Postman, you can import the file `demo/postman/Springboot Sample App.postman_collection.json` for the endpoints, and the file `demo/postman/Local Spring Boot Application.postman_environment.json` for the environment (in this case, only for set the variable origin to http://localhost:7000)
- **PL/SQL Development**: In SQL developer create a connection as developer, to your service
- **Microservices development**: Import the Spring Boot project in your favourite java development tool. The project for the developer is located in demo/environments/dev (after running the initialization script). NOTE: Currently this sample has been create with Visual Studio Code for my personal comfort, but this is not (IMHO) the best tool for Spring development.

# Executing the demo
## Initial test of application
- Start your SQL developer and connect with the development user (demo_dev) to database
- Start Postman and select the `Spring Sample App` workspace
- Start your favourite terminal (I use the embedded terminal in VSCode) and move to development environment
  `cd environments/dev`. Start the SpringBoot application with `./app-run.sh``
- From Postman (or your favourite tool)
  - Check the application health using the `Actuator health` endpoint
  - Using the `Get All Products`, `Create Products`and `Get Product by id`feed some products to sample. Be aware that initially the product only have id and name (relevant for the JSON body in POST/Create and PUT/Update)
## Create and deploy the V1 for Canary testing
- Modify the simple test function using the SQL Developer. E.g. changing directly the greeting text in function `Greeting`
  ```
  create or replace FUNCTION Greeting RETURN VARCHAR2 AS
  BEGIN
    RETURN 'Hello, A BRAVE NEW world!!!';
  END;
  /
  ```
- Test the function in Postman (there is no need to restart application)
- As developer, you close and deliver a V1 version. For this, execute the script
  ```
  demo/scripts/dev-publish-version.sh v1
  ```
  **TODO**: The current version does not check if you deploy twice the same version tag, but it will fail later.
- Optional: Check the deployment

  - In development environment `./environments/dev` execute `git log`. You have to see the last commit (`HEAD -> dev`) tagged with `V1`, and synchronized with `origin/dev`
  ```
  commit 0ff68ece30303530708a05b1306891d848e97df3 (HEAD -> dev, tag: V1, origin/dev)  
  ```

  - Check de Liquibase generated scripts in `./environments/dev/database/liquibase`. Notice that the scripts contains the full schema definition.

- As operation, deploy the application for Canary testing. For this, execute the script

  ```
  demo/scripts/pre-deploy-version-in-test v1
  ```

- Optional: Check the deployment in pre environment

  - In preproduction environment `./environments/pre` execute `git log`. You have to see the last commit (`HEAD -> dev`) tagged with `V1`, and synchronized with `origin/dev` and `origin/pre`
  ```
  commit 0ff68ece30303530708a05b1306891d848e97df3 (HEAD -> pre, tag: V1, origin/pre, origin/dev) 
  ```

  - Check de Liquibase generated log files in `./environments/dev/database/liquibase`. You can see the DDLs executed in the environment

  - In preproduction schema/database the content of the tables `DATABASECHANGELOG`(Liquibase native) and `DATABASECHANGELOG_ACTION`(SQLcl extension)


## Do Canary testing
- Ensure that dev application is stopped. Currently the both enviroments share the port 7000, so cannot coexist in the same PC
- Start your favourite terminal and move to preproduction environment `cd environments/dev`. Start the SpringBoot application with `./app-run.sh`
- In Postman, call the `Greeting` function. You will set the previous (v0) message `"greeting": "Hello, world!!!"` because by default all users are in B (previous) scenary
- Using Postman, use the `Procedure: Set Current Edition` to change your scenario to `EDITION_V1``
- Repeat the previous call to `Greeting` and you will get the V1 message `"greeting": "Hello, A BRAVE NEW world!!!"`
- NOTE: In real world scenarios, we can use several alternatives. In microservices we can create differente database services (pointing to the different editions) and have a pool of containers, some pointing to V0 services and the canary testers pointing to V1.


