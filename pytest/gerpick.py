"""
_summary_
"""

import time
import os
import logging
import argparse
import fnmatch
import sys
from datetime import datetime
from pathlib import Path
import utils.cfg_helper as cfg
import utils.test_helper as test
import utils.menu_helper as menu


now = datetime.now()
timestamp = now.strftime("%Y%m%d_%H%M")

parser = argparse.ArgumentParser(
    description="Test script arguments",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
)
parser.add_argument("-f", "--file", default="*.json", help="test config file")
parser.add_argument("-t", "--timeout", default="1", help="minimal waiting time")
parser.add_argument("-d", "--dir", default="tests", help="directory with test configs")
parser.add_argument("-o", "--output", default="output", help="directory for logs")
parser.add_argument("-m", "--menu", default="false", help="run a menu system")

args = parser.parse_args()
config = vars(args)

log_dir = config["output"]
test_dir = config["dir"]
test_file = config["file"]
test_menu = config["menu"]
test_menu = "true"

test_list = []

for file in os.listdir(test_dir):
    if fnmatch.fnmatch(file, test_file):
        test_list.append(os.path.join(test_dir, file))

if len(test_list) < 1:
    print("There are no test configs to run test.\nDone.")
    sys.exit(0)

for next_test in test_list:

    test_cfg = cfg.read_test_cfg(next_test)
    time_out = int(config["timeout"])

    test_log = f"{log_dir}/{timestamp}-{Path(next_test).stem}.log"

    if not os.path.isdir(log_dir):
        os.mkdir(log_dir)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)8s] %(message)s",
        handlers=[logging.FileHandler(test_log), logging.StreamHandler()],
    )

    log = logging.getLogger(__name__)

    if test_menu == "true" :
        #print("This is where we run the test menu\nDone.")
        menu.init_menu(test_list)
        sys.exit(0)

    test_list = cfg.get_test_list(test_cfg)
    log.info("There are {} tests in the list.".format(len(test_list)))

    testbed_list = cfg.get_environment(test_cfg)
    log.info("Test environment includes {} test beds.".format(len(testbed_list)))

    testbed = testbed_list[0]

    controllers = cfg.get_testbed(testbed)


    for each in test_list:

        variables = cfg.get_variables(each)

        if variables == {}:
            variables['ess_id'] = ['01']

        var_key = list(variables.keys())
        var_list = variables[var_key[0]]

        steps = cfg.get_test_steps(each)
        expectations = cfg.get_expectation(each)
        environments = cfg.get_test_env(each)

        for test_env in environments:
            test_bed = cfg.get_testbed(testbed)

            
            for var in var_list:

                each["new_name"] = each["name"].replace("<{}>".format(var_key[0]),var)

                log.info("====> Test case '{} - {}' has {} steps and will run on {} test bed.".format(
                                            each["new_name"], each["id"], len(steps), len(environments)))

                log.debug("Variable '<{}>' equal to '{}'.".format(var_key[0], var))
                for test_step in steps:

                    test.execute_step(test_bed, test_step, var, var_key[0])
                for validation in expectations:
                    tolerance_str = ""

                    try:
                        tolerance_str = validation["tolerance"]
                    except KeyError:
                        log.debug(
                            "There is no parameter 'tolerance' in validation, which means 'no tolerance'."
                        )
                    tolerance, tolerance_relative = test.get_tolerance(tolerance_str)

                    expected_result = validation["value"]

                    attempts = 5
                    try:
                        attempts = validation["waiting"]
                    except KeyError:
                        log.debug("There is no waiting parameter for validation.")

                    log.info(
                        "Test will make up to {} attempts every {} seconds to get expected result.".format(
                            attempts, time_out
                        )
                    )

                    for attempt in range(0, attempts):
                        time.sleep(time_out)
                        log.info("Attempt - {}.".format(attempt))
                        test_success = False
                        actual_result = []
                        result = ""
                        result = test.execute_step(test_bed, validation, var, var_key[0])
                        if isinstance(result, list):
                            actual_result = result
                        else:
                            actual_result.append(result)
                        log.debug("Actual result is '{}'.".format(actual_result))
                        log.debug("Expected result is '{}'.".format(expected_result))

                        if len(actual_result) != len(expected_result):
                            log.debug(
                                "Attempt {} failed because length of actual result doesn't match expectations.".format(
                                    attempt
                                )
                            )
                            continue

                        if len(actual_result) == 0:
                            log.debug(
                                "Expected and actual results are empty - no point to compare them/"
                            )
                            test_success = True
                            break

                        for actual, expected in zip(actual_result, expected_result):
                            test_passed = test.evaluate(
                                actual, expected, tolerance, tolerance_relative
                            )
                            if not test_passed:
                                log.debug("Test failed")
                                test_success = False
                                break
                            else:
                                log.debug("Test passed")
                                test_success = True
                        if test_success:
                            break

                    test.report_test(each, test_success, actual_result, expected_result)  # type: ignore

    print("Done with test {}.".format(next_test))
