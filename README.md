# python-wrapper
### Environment stability wrapper for general python executions

Can be used in 2 entrypoint methods:
1. `shell/run.sh` which runs baremetial on the machine
2. `shell/runDocker.sh` which creates, maintains, and runs a container to then execute `shell/run.sh`


Order of execution:
Execute `shell/runDocker.sh` :
    1. Check if `docker` is installed and fail out if not
    2. Export environment variables from `configuration/environment.properties` if `ALREADY_SOURCED` is not already in the environment
    3a. if :
        * Docker image does not exist
        * Repository HEAD has changed
        * `FORCE_DOCKER_REBUILD` is set to "TRUE"
        
        Execute `shell/buildImage.sh` :
        1. Export environment variables from `configuration/environment.properties` if `ALREADY_SOURCED` is not already in the environment
        2. Deactivate and delete any existing bare metal Python virtual environment
        3. Get Python base Docker image
        4. Delete old python-wrapper Docker image
        5. Create a new python-wrapper Docker image
    3b. Otherwise : Deactivate and delete any existing bare metal Python virtual environment
    4. Execute `shell/run.sh` :
        1. Export environment variables from `configuration/environment.properties` if `ALREADY_SOURCED` is not already in the environment
        2. Create, activate, and upgrade Python virtual environment if not already existing
        3. Install requirements from `requirements.txt`
        4. Execute `python/main.py` :
            1. Create Python log handler
            2. Run placeholder `log.info('[ DONE ] Run pythonFunction() entry point >>>')`
            The above should be replaced with production code. I am using this as a base project for other Python projects i start

