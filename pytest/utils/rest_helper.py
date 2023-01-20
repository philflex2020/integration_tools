import logging
import requests
from requests.auth import HTTPBasicAuth
import urllib3

log = logging.getLogger(__name__)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)  # type: ignore


def get(uri, controller):
    ip_address = controller["ip"]
    https_port = controller["https"]
    url = "https://{}:{}/rest{}".format(ip_address, https_port, uri)
    log.info("GET request to URL {}.".format(url))
    response = requests.get(
        url,
        auth=HTTPBasicAuth(controller["ui_user"], controller["ui_code"]),
        verify=False,
        timeout=10
    )
    value = _read_response(response)
    return value


def put(uri, controller, value):
    ip_address = controller["ip"]
    https_port = controller["https"]
    str_value = str(value).lower()
    url = "https://{}:{}/rest{}/{}".format(ip_address, https_port, uri, str_value)
    log.info("PUT request to URL {}.".format(url))
    response = requests.put(
        url,
        auth=HTTPBasicAuth(controller["ui_user"], controller["ui_code"]),
        data="",
        verify=False,
        timeout=10
    )
    value = _read_response(response)
    return value


def _read_response(response):
    status_code = response.status_code
    value = {"value": "ERROR"}
    if 200 <= status_code < 300:
        log.debug("Successful REST API request. Status code is {}.".format(status_code))
        value = response.json()
    else:
        log.debug(
            "Unsuccessful REST API request. Status code is {}.".format(status_code)
        )
    log.info("REST status is {}. Body is : {}.".format(status_code, value))
    return value
