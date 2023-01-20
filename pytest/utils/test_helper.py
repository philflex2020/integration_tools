import logging
import time
from . import hos_helper as hos
from . import cfg_helper as cfg
from . import rest_helper as rest


log = logging.getLogger(__name__)


def execute_step(test_bed, step, var, var_name):
    result = ""
    controller = cfg.get_controller(test_bed, step["controller"])
    log.info("Controller to execute is {}.".format(controller["name"])) # type: ignore
    uri = step["uri"].replace("<{}>".format(var_name),var)
    action = step["action"]
    value = step["value"]
    if isinstance(value, str):
        value = value.replace("<{}>".format(var_name),var)

    if action == "fims_set":
        hos.fims_set(uri, value, controller)
    elif action == "fims_get":
        result = hos.fims_get(uri, controller)
    elif action == "rest_get":
        result = rest.get(uri, controller)
    elif action == "rest_put":
        rest.put(uri, controller, value)
    elif action == "pause":
        log.info("Pause for {} seconds.".format(value))
        time.sleep(float(value))
    else:
        log.error("Unsupported step!")

    return result


def get_tolerance(tolerance_str):
    log.debug("Checking type and level of tolerance for result validation.")
    tolerance = 0
    tolerance_relative = False
    if tolerance_str != "":
        if tolerance_str.endswith("%"):
            log.debug("Tolerance provided in %")
            tolerance_str = tolerance_str[:-1]
            tolerance_relative = True
            tolerance = float(tolerance_str) / 100
        else:
            log.debug("Tolerance provided as absolute value.")
            tolerance = float(tolerance_str)

    return tolerance, tolerance_relative


def validation(actual, expected, tolerance, tolerance_relative):
    log.debug(
        "Checking actual value '{}' against expected '{}'.".format(actual, expected)
    )
    validation_passed = True
    if isinstance(actual, (int, float)):
        log.debug(
            "Actual value is numeric (int or float), so assume expected value is numeric as well."
        )
        if tolerance_relative:
            try:
                percentage = (actual - expected) / expected
            except ZeroDivisionError:
                log.debug("Caught division by zero")
                percentage = 1
        else:
            percentage = actual - expected
        log.debug("Deviation from expected value is {}.".format(percentage))
        if abs(percentage) > tolerance:
            log.debug("It is more than tolerance of the test. Validation failed.")
            validation_passed = False
        else:
            log.debug("It is less than tolerance of the test. Validation passed.")
    else:
        log.debug("Actual value is not digital.")
        if actual != expected:
            log.debug("Actual value does not match expectation. Validation failed.")
            validation_passed = False
        else:
            log.debug("Actual value match expectation. Validation passed.")

    return validation_passed


def evaluate(incoming_result, expected_result, tolerance, tolerance_relative):

    validation_status = {}
    actual_result = {}
    if isinstance(incoming_result, dict):
        actual_result = incoming_result
    else:
        actual_result["naked_value"] = incoming_result

    for key in expected_result.keys():
        validation_status[key] = False
        try:
            actual = actual_result[key]
        except KeyError:
            log.debug("Missing key '{}' in actual result.".format(key))
            break
        expected = expected_result[key]
        validation_status[key] = validation(
            actual, expected, tolerance, tolerance_relative
        )
        if validation_status[key]:
            log.debug("Validation of key '{}' passed.".format(key))
            continue
        else:
            log.debug("Validation of key '{}' failed.".format(key))
            break

    final_result = False
    if all(value is True for value in validation_status.values()):
        log.debug("Validation for all keys was successful.")
        final_result = True

    return final_result


def report_test(each, test_passed, actual_result, expected_result):
    msg_1 = "Test '{} - {}'.".format(each["new_name"], each["id"])
    msg_2 = "      Actual result   - ({})".format(actual_result)
    msg_3 = "      Expected result - ({})".format(expected_result)
    if test_passed:
        log.info("SUCCESS: {}\n{}\n{}".format(msg_1, msg_2, msg_3))
        print("\nPASS: ", msg_1)
        print()
    else:
        log.info("FAILURE: {}\n{}\n{}".format(msg_1, msg_2, msg_3))
        print("\nFAIL: Test '{} - {}'.".format(each["new_name"], each["id"]))
        print("      Actual result   - ({})".format(actual_result))
        print("      Expected result - ({})".format(expected_result))
        print()
