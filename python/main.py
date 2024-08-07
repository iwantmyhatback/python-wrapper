from os import environ as osEnviron
import logging as log


################
## Executions ##
################

# Set the loggin level for this entire script set
if osEnviron.get("LOG_LEVEL"):
    LOG_LOCATION = str(osEnviron.get("LOG_LOCATION", "python-output.log"))
    LOG_LEVEL = str(osEnviron.get("LOG_LEVEL", "INFO")).upper()
    log.root.handlers = []
    log.basicConfig(
        level=LOG_LEVEL,
        format="[%(levelname)s]\t%(message)s",
        handlers=[
            log.FileHandler(filename=LOG_LOCATION, mode='w'),
            log.StreamHandler()
        ]
    )

log.info('[SCRIPT] Completed Environmental Setup!')

# Bring in some python you want to run here...
# ie:
# from pythonFileSomewhere import somePythonFunction
# somePythonFunction()
log.info('[ DONE ] Run somePythonFunction() entry point >> HERE!')