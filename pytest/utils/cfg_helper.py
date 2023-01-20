import logging
import sys
from . import general_helper as helper
from . import docker_helper as docker


log = logging.getLogger(__name__)


def read_test_cfg(cfg_file):
    cfg_data = helper.read_json(cfg_file)
    return cfg_data


def get_test_list(cfg_data):
    log.debug("Getting the list of tests to execute.")
    return _get_testdetails(cfg_data, "tests")


def get_environment(cfg_data):
    log.debug("Getting the list of testbeds, where tests will run.")
    return _get_testdetails(cfg_data, "testbeds")


def _get_testdetails(cfg_data, test_details):
    log.debug("Getting list of {} from test config file.".format(test_details))
    try:
        return cfg_data[test_details]
    except IndexError as my_exception:
        msg = "There must be at least one testbed to execute test."
        log.error(msg)
        log.error(my_exception)
        sys.exit(msg)


def get_test_steps(test_id):
    log.debug(
        "Getting test steps for the test '{}' (id={}).".format(
            test_id["name"], test_id["id"]
        )
    )
    return _get_testdata(test_id, "steps")


def get_test_env(test_id):
    log.debug(
        "Getting test environment for the test '{}' (id={}).".format(
            test_id["name"], test_id["id"]
        )
    )
    return _get_testdata(test_id, "testbeds")


def get_variables(test_id):
    variables_list = []
    variables = {}
    log.debug(
        "Getting test variables for the test '{}' (id={}).".format(
            test_id["name"], test_id["id"]
        )
    )
    variables_list = _get_testdata(test_id, "variables")
    if len(variables_list) != 0:
        for each in variables_list:
            var_id = each["var"]
            var_type = each["type"]
            var_size = each["size"]
            var_list = _var_convertor(each["description"])
            if var_type == "int":
                var_list = [int(x) for x in var_list]
            elif var_list == "float":
                var_list = [float(x) for x in var_list]
            else:
                var_list = [str(x).zfill(var_size) for x in var_list]

            variables[var_id] = var_list

    return variables


def _var_convertor(var_description):
    var_list = []
    
    if "range" in var_description:
        log.debug("Will generate list of variables based on range.")
        str_list = _var_str_cleanup(var_description, "range")
        if len(str_list) == 2:
            str_list[2] = "1"
        if len(str_list) == 3:
            for i in range(int(str_list[0]), int(str_list[1])+1, int(str_list[2])):
                var_list.append(i)
        else:
            var_list = ["ERROR", "ERROR"]
    elif "list" in var_description:
        log.debug("Will generate list of variables based on existing list.")
        var_list = _var_str_cleanup(var_description, "list")
    else:
        var_list = ["ERROR", "ERROR"]

    log.debug("List of variables: '{}'.".format(var_list))
    return var_list


def _var_str_cleanup(my_string, key_word):
    new_string = my_string.replace(key_word, "").replace("(","").replace(")","")
    new_list = new_string.split(",")
    new_list = [x.strip() for x in new_list]
    return new_list


def get_expectation(test_id):
    log.debug(
        "Getting expected results for the test '{}' (id={}).".format(
            test_id["name"], test_id["id"]
        )
    )
    return _get_testdata(test_id, "result")


def _get_testdata(test_id, data_type):
    log.debug(
        "Getting {} for the test '{}' (id={}).".format(
            data_type, test_id["name"], test_id["id"]
        )
    )
    test_data = []
    try:
        test_data = test_id[data_type]
    except IndexError as my_exception:
        log.warning(
            "Unable to get data for the test '{}' (id={}).".format(
                test_id["name"], test_id["id"]
            )
        )
        log.warning(my_exception)
    except KeyError:
        log.warning(
            "Unable to get data for the test '{}' (id={}).".format(
                test_id["name"], test_id["id"]
            )
        )
    return test_data


def get_testbed(test_bed):
    log.debug(
        "Getting list of controllers in testbed '{}' (id={}).".format(
            test_bed["name"], test_bed["id"]
        )
    )
    response = []
    controllers = test_bed["controllers"]
    if len(controllers) > 0:
        for each in controllers:
            response.append(each)
    else:
        log.warning("There is no controllers in selected testbed.")
    controllers = get_controllers(response)
    return controllers


def get_controller(controllers, controller_id):
    log.debug(
        "Getting controller information for controller '{}'.".format(controller_id)
    )
    for each in controllers:
        if each["id"] == controller_id:
            return each


def get_controllers(controllers):
    log.debug("Getting all controllers information in testbed.")
    for each in controllers:
        each["ui_user"] = "python_rest"
        each["ui_code"] = "flexgen1A!"
        if "." in each["id"]:
            log.debug("Will use SSH to connect to controller.")
            each["connection"] = (each["user"], each["pass"], each["id"], 22)
            each["ip"] = each["id"]
            each["https"] = "443"
        else:
            log.debug("Will use 'docker exec' to connect to controller.")
            each["connection"] = docker.get_docker_id(each["id"])
            each["ip"] = "127.0.0.1"
            ports = docker.get_exposed_ports(each["connection"])
            each["https"] = ports["443"]
    return controllers


def get_required_testbeds(test_cfg):
    log.debug("Getting the list of required testbeds for all tests.")
    test_list = get_test_list(test_cfg)
    all_testbeds = []
    for each in test_list:
        all_testbeds = all_testbeds + each["testbeds"]
    return list(set(all_testbeds))
