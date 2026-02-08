from os import environ as osEnviron
import platform
import socket
import logging as log
from pathlib import Path


################
## Executions ##
################

def main():
    # Set the logging level for python
    LOG_LOCATION = osEnviron.get("LOG_LOCATION", "")
    LOG_LEVEL = osEnviron.get("LOG_LEVEL", "INFO").upper()

    log.root.handlers = []
    basicConfigHandler = [log.StreamHandler()]
    if LOG_LOCATION:
        logLocationPath = Path(LOG_LOCATION)
        logLocationPath.parent.absolute().mkdir(
            parents=True,
            exist_ok=True
        )
        basicConfigHandler.append(
            log.FileHandler(
                filename=logLocationPath.absolute(),
                mode='w'
            )
        )

    log.basicConfig(
        level=LOG_LEVEL,
        format="[%(levelname)s]\t%(message)s",
        handlers=basicConfigHandler
    )

    system_info()
    log.info('[SCRIPT] Completed Environmental Setup!')

    # Bring in some python you want to run here...
    # ie:
    # from pythonFileSomewhere import somePythonFunction
    # somePythonFunction()
    log.info('[ DONE ] Run somePythonFunction() entry point >> HERE!')




def system_info():
    try:
        sys_info = {
            'Platform': platform.system(),
            'Platform_release': platform.release(),
            'Platform_version': platform.version(),
            'Architecture': platform.machine(),
            'Hostname': socket.gethostname(),
            'Processor': platform.processor(),
        }
        log.info('[PY_ENV] System Information:')
        for key, value in sys_info.items():
            log.info(f'[PY_ENV] >>\t{key}: {value}')
        return sys_info
    except Exception:
        log.exception('[PY_ENV] Failed to collect system information')


if __name__ == "__main__":
    main()
