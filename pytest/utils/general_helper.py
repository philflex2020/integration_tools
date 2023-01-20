import os
import sys
import json
import logging
#from . import ssh_helper as ssh
from . import docker_helper as docker


log = logging.getLogger(__name__)


def write_json(json_object, file_name):
    log.debug("Writing JSON file '{}'.".format(file_name))
    json_string = json.dumps(json_object,indent=4)
    try:
        with open(file_name, "w") as json_file:
            json_file.write(json_string)
    except IOError as my_exception:
        msg = "Unable to write config file '{}'.".format(file_name)
        log.error(msg)
        log.error(my_exception)
        sys.exit(msg)

def write(file_object, file_name):
    log.debug("Writing  file '{}'.".format(file_name))
    try:
        with open(file_name, "w") as json_file:
            json_file.write(file_object)
    except IOError as my_exception:
        msg = "Unable to write config file '{}'.".format(file_name)
        log.error(msg)
        log.error(my_exception)
        sys.exit(msg)


def read_json(file_name):
    log.debug("Reading JSON file '{}'.".format(file_name))
    try:
        with open(file_name, encoding='utf-8') as json_file:
            config_file = json.load(json_file)
            return config_file
    except IOError as my_exception:
        msg = "Unable to read config file '{}'.".format(file_name)
        log.error(msg)
        log.error(my_exception)
        sys.exit(msg)

def read(file_name):
    log.debug("Reading file '{}'.".format(file_name))
    try:
        with open(file_name, encoding='utf-8') as json_file:
            config_file = json_file.read()
            return config_file
    except IOError as my_exception:
        msg = "Unable to read config file '{}'.".format(file_name)
        log.error(msg)
        log.error(my_exception)
        sys.exit(msg)


def delete_file(file_name):
    if os.path.exists(file_name):
        log.debug("Deleting file '{}'.".format(file_name))
        try:
            os.remove(file_name)
        except OSError as my_exception:
            log.warning("Failed to delete file '{}'.".format(file_name))
            log.warning(my_exception)


def divider(div_length = 30):
    print(div_length * "=")


def download_file(local_path, remote_path, connect_info):
    local_path = local_path.strip()
    remote_path = remote_path.strip()
    log.debug("Downloading remote file '{}'.".format(remote_path))
    if isinstance(connect_info, str):
        docker.copy_from(connect_info, local_path, remote_path)
    else:
        log.error("No SSH yet Downloading remote file '{}'.".format(remote_path))
        #ssh.copy_from(connect_info, remote_path, local_path)

def upload_file(local_path, remote_path, connect_info):
    local_path = local_path.strip()
    remote_path = remote_path.strip()
    log.debug("Uploading remote file '{}'.".format(remote_path))
    if isinstance(connect_info, str):
        docker.copy_to(connect_info, local_path, remote_path)
    else:
        log.error("No SSH yet Downloading remote file '{}'.".format(remote_path))
        #ssh.copy_from(connect_info, remote_path, local_path)


def read_remote_json(remote_path, connect_info):
    local_path = "temporary.json"
    download_file(local_path, remote_path, connect_info)
    local_dict = read_json(local_path)
    delete_file(local_path)
    return local_dict


def print_debug(msg):
    print(msg)
    divider()
