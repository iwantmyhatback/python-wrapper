from os import environ as osEnviron
import logging as log


################
## Executions ##
################

def main():
    # Set the loggin level for this entire script set
    LOG_LOCATION = str(osEnviron.get("LOG_LOCATION", ""))
    LOG_LEVEL = str(osEnviron.get("LOG_LEVEL", "INFO")).upper()

    log.root.handlers = []
    basicConfigHandler = [log.StreamHandler()]
    if LOG_LOCATION:
        basicConfigHandler.append(log.FileHandler(filename=LOG_LOCATION, mode='w'))

    log.basicConfig(
        level=LOG_LEVEL,
        format="[%(levelname)s]\t%(message)s",
        handlers=basicConfigHandler
    )

    log.info('[SCRIPT] Completed Environmental Setup!')

    # Bring in some python you want to run here...
    # ie:
    # from pythonFileSomewhere import somePythonFunction
    # somePythonFunction()
    log.info('[ DONE ] Run somePythonFunction() entry point >> HERE!')




if __name__ == "__main__":
    main()