from os import environ as osEnviron
import logging as log


################
## Executions ##
################

# Set the loggin level for this entire script set
if osEnviron.get("PYTHON_LOG_LEVEL"):
    PYTHON_LOG_LEVEL = str(osEnviron.get("PYTHON_LOG_LEVEL")).upper()
    log.root.handlers = []
    log.basicConfig(
        level=PYTHON_LOG_LEVEL,
        format="[%(levelname)s] %(message)s",
        handlers=[
            log.FileHandler(filename="output.log", mode='w'),
            log.StreamHandler()
        ]
    )

print('Run some python stuff')
