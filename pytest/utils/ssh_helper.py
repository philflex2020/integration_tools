import logging
import paramiko
import subprocess
 

log = logging.getLogger(__name__)
logging.getLogger("paramiko").setLevel(logging.WARNING)


def ssh_connect(user_name, user_pass, server_name, ssh_port=22):
    log.debug(
        "Connecting to the server with IP {} as {}.".format(server_name, user_name)
    )
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(server_name, ssh_port, user_name, user_pass)
    return ssh


def remote_command(command, connect_info):
    user_name, user_pass = connect_info[0], connect_info[1]
    controller_ip, controller_port = connect_info[2], connect_info[3]
    log.debug(
        "Connecting as '{}' to the '{}:{}'.".format(
            user_name, controller_ip, controller_port
        )
    )
    if controller_ip == "localhost":
        log.info("Executing local command '{}'.".format(command.split()))
        lines = subprocess.run(command.split())
    else:
        connection = ssh_connect(user_name, user_pass, controller_ip, controller_port)
        log.debug("Executing remote command '{}'.".format(command))
        _, stdout, _ = connection.exec_command(command)
        lines = stdout.readlines()
    log.debug("Response is: '{}'.".format(lines))
    connection.close()
    return lines


def copy_from(connect_info, remote_path, local_path):
    log.debug(
        "Copy file from remote ({}) to local ({}) file system.".format(
            remote_path, local_path
        )
    )
    _fg_scp(connect_info, remote_path, local_path)


def copy_to(connect_info, remote_path, local_path):
    log.debug(
        "Copy file from local ({}) to remote ({}) file system.".format(
            remote_path, local_path
        )
    )
    _fg_scp(connect_info, local_path, remote_path)


def _fg_scp(connect_info, path_from, path_to):
    log.debug("Copy {} to {}.".format(path_from, path_to))
    user_name, user_pass = connect_info[0], connect_info[1]
    controller_ip, controller_port = connect_info[2], connect_info[3]
    connection = ssh_connect(user_name, user_pass, controller_ip, controller_port)
    sftp = connection.open_sftp()
    sftp.get(path_from, path_to)
    sftp.close()
    connection.close()
