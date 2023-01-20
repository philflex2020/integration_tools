import logging
import subprocess

log = logging.getLogger(__name__)

def execute(cmd):
    log.debug("Executing command '{}'.".format(cmd))
    response = subprocess.run(cmd,
        universal_newlines = True,
        stdout = subprocess.PIPE)
    return response.stdout.strip().splitlines()


def start_docker(docker_name):
    cmd = "docker-compose up -d {}".format(docker_name)
    response = execute(cmd)
    return response


def stop_docker(docker_name):
    cmd = "docker-compose stop {}".format(docker_name)
    response = execute(cmd)
    return response