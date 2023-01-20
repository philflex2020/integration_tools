import logging
import subprocess
import json


log = logging.getLogger(__name__)


def get_docker_id(docker_type):
    log.debug("Getting ID for docker '{}'.".format(docker_type))
    cmd = 'docker ps -aqf "name={}"'.format(docker_type)
    responses = _execute_cmd(cmd)
    docker_id = []
    if len(responses) > 0:
        docker_id = responses[0]
    log.debug("Docker Name {} ID is {}.".format(docker_type, docker_id))
    return docker_id


def exec_in(docker_id, docker_cmd):
    log.debug("Running command '{}' in docker {}.".format(docker_cmd, docker_id))
    cmd = "docker exec {} {}".format(docker_id, docker_cmd)
    responses = _execute_cmd(cmd)
    log.debug("Response from running command is '{}'.".format(responses))
    return responses

def exec_inbg(docker_id, docker_cmd):
    log.debug("Running command '{}' in docker {}.".format(docker_cmd, docker_id))
    cmd = "docker exec -d {} {}".format(docker_id, docker_cmd)
    responses = _execute_cmd(cmd)
    log.debug("Response from running command is '{}'.".format(responses))
    return responses


def copy_from(docker_id, local_path, remote_path):
    log.debug("Copy file from docker {} to local file system.".format(docker_id))
    cmd = "docker cp {}:/{} {}".format(docker_id, remote_path, local_path)
    response = _execute_cmd(cmd)
    return response


def copy_to(docker_id, local_path, remote_path):
    log.debug("Copy local file '{}' to the docker {}.".format(local_path, docker_id))
    cmd = "docker cp {} {}:/{}".format(local_path, docker_id, remote_path)
    response = _execute_cmd(cmd)
    return response


def get_pid(docker_id, process_name):
    log.debug(
        "Getting PID for the process '{}' running in docker {}.".format(
            process_name, docker_id
        )
    )
    pid_list = []
    matched_lines = []
    cmd = "docker container top {}".format(docker_id)
    response = _execute_cmd(cmd)
    for line in response:
        if process_name in line:
            matched_lines.append(line)
    for each in matched_lines:
        pidof = each.split()[1].strip()
        pid_list.append(pidof)
    return pid_list


def get_docker_ip(docker_id):
    log.debug("Getting internal IP address for docker {}.".format(docker_id))
    #cmd = "docker inspect -f '{{{{range .NetworkSettings.Networks}}}}{{{{.IPAddress}}}}{{{{end}}}}' {}".format(docker_id)
    cmd = "docker inspect  {}".format(docker_id)
    response = _execute_cmd(cmd)
    resp=' '.join(response)
    #print(resp)

    res=json.loads(resp)
    #print(res[0])
    try:
        ip=res[0]["NetworkSettings"]["IPAddress"]
    except:
        ip="Unknown"
    return ip


def get_exposed_ports(docker_id):
    log.debug("Getting internal IP address for docker {}.".format(docker_id))
    cmd = 'docker container ls --format "table {}" --filter "id={}"'.format(
        "{{.Ports}}", docker_id
    )
    response = _execute_cmd(cmd)
    exposed_ports = {"443": ""}
    if len(response) == 2:
        ports = response[1].strip().split(", ")
        for each in ports:
            try:
                host_port, docker_port = each.split("->")
            except ValueError:
                host_port = ""
                docker_port = each
            docker_port = docker_port[:-4]
            if host_port.startswith("0.0.0.0"):
                host_port = host_port[8:]
            exposed_ports[docker_port] = host_port
    return exposed_ports


def _execute_cmd(cmd):
    log.debug("Executing command '{}'.".format(cmd))
    try:
        response = subprocess.run(
            cmd, universal_newlines=True, stdout=subprocess.PIPE, text=True, shell=True, check=True
        )
        #return response
        return response.stdout.strip().splitlines()
    except:
        log.info("Error Executing command '{}'.".format(cmd))
        return []


def start_docker(docker_id):
    log.debug("Starting docker '{}' in detached mode.".format(docker_id))
    cmd = "docker-compose up -d {}".format(docker_id)
    response = _execute_cmd(cmd)
    return response


def stop_docker(docker_id):
    log.debug("Stopping docker container '{}'.".format(docker_id))
    cmd = "docker-compose stop {}".format(docker_id)
    response = _execute_cmd(cmd)
    return response
