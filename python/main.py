from os import environ as osEnviron
import logging as log
from pathlib import Path


################
## Executions ##
################

def main():
    # Set the logging level for python
    LOG_LOCATION = str(osEnviron.get("LOG_LOCATION", ""))
    LOG_LEVEL = str(osEnviron.get("LOG_LEVEL", "INFO")).upper()

    log.root.handlers = []
    basicConfigHandler = [log.StreamHandler()]
    if LOG_LOCATION:
        logLocationPath = Path(LOG_LOCATION)
        logLocationPath.parent.absolute().mkdir(
            parents=True, 
            exist_ok=True
        )
        basicConfigHandler.append(log.FileHandler(filename=logLocationPath.absolute(), mode='w'))

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