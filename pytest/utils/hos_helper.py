import json
import logging

#from . import ssh_helper as ssh
from . import docker_helper as docker


log = logging.getLogger(__name__)


def fims(params, controller):
    fims_cmd = "fims_send " + params
    response_dict = {}
    log.debug("Executing command '{}'.".format(fims_cmd))
    connect_info = controller['connection']
    if isinstance(connect_info, str):
        if connect_info == "docker":
            response = docker.exec_in(connect_info, fims_cmd)
        else:
            log.debug("No SSH Executing command '{}'.".format(fims_cmd))
            #response = ssh.remote_command(fims_cmd, connect_info)
            
    else:
        log.debug("No SSH Executing command '{}'.".format(fims_cmd))
        #response = ssh.remote_command(fims_cmd, connect_info)
    if len(response) > 0:
        response_dict = json.loads(response[0])
    log.info("Action response is: {}.".format(response_dict))
    return response_dict


def fims_get(uri, controller):
    params = "-m get -r /me -u {}".format(uri)
    log.info("Executing FIMS GET for {}.".format(uri))
    response_dict = fims(params, controller)
    return response_dict


def fims_set(uri, value, controller):
    if isinstance(value, bool):
        my_value = str(value).lower()
    else:
        my_value = value
    params = "-m set -u {} -- {}".format(uri, my_value)
    log.info("Executing FIMS SET for {}. Value is {}.".format(uri, my_value))
    response_dict = fims(params, controller)
    return response_dict


def service_restart(service_name, passwd, connect_info):
    service_command(service_name, "restart", passwd, connect_info)


def service_start(service_name, passwd, connect_info):
    service_command(service_name, "start", passwd, connect_info)


def service_stop(service_name, passwd, connect_info):
    service_command(service_name, "stop", passwd, connect_info)


def service_command(service_name, cmd, passwd, connect_info):
    full_cmd = "echo " + passwd + " | sudo -S systemctl " + cmd + " " + service_name
    #ssh.remote_command(full_cmd, connect_info)


def service_status(service_name, connect_info):
    full_cmd = "systemctl status " + service_name
    #response = ssh.remote_command(full_cmd, connect_info)
    words = ["error", "error"]
    for each in response:
        new_line = each.strip().lower()
        if new_line.startswith("active:"):
            words = new_line.split(" ")
    return words[1]
