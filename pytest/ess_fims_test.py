# TWINS and ESS Controller containers must be launched to run this test
import subprocess

FIMS_SEND = "/usr/local/bin/fims_send"
DOKEC_ID = "6a17f022115c"

def fimsSet(uri, value):
    body = '{"value":' + str(value) + '}'
    response = subprocess.run(["docker", "container", "exec", DOKEC_ID, FIMS_SEND, "-m", "set", "-u", uri, body], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    print("Response from SET:", response.stdout)

def fimsGet(uri):
    response = subprocess.run(["docker", "container", "exec", DOKEC_ID, FIMS_SEND, "-m", "get", "-r", "/me", "-u", uri], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    print("Response from GET:", response.stdout)

# Start of Test

# Active Power starts at 0
fimsGet("/assets/pcs/pcs_1/active_power")
fimsGet("/assets/pcs/pcs_2/active_power")

# Active Power set to -400
fimsSet("/assets/pcs/pcs_1/active_power", -400)
fimsSet("/assets/pcs/pcs_2/active_power", -400)
fimsGet("/assets/pcs/pcs_1/active_power")
fimsGet("/assets/pcs/pcs_2/active_power")

# Active Power set to -100
fimsSet("/assets/pcs/pcs_1/active_power", -100)
fimsSet("/assets/pcs/pcs_2/active_power", -100)
fimsGet("/assets/pcs/pcs_1/active_power")
fimsGet("/assets/pcs/pcs_2/active_power")

# Active Power set to 0
fimsSet("/assets/pcs/pcs_1/active_power", 0)
fimsSet("/assets/pcs/pcs_2/active_power", 0)
fimsGet("/assets/pcs/pcs_1/active_power")
fimsGet("/assets/pcs/pcs_2/active_power")

# Active Power set to 100
fimsSet("/assets/pcs/pcs_1/active_power", 100)
fimsSet("/assets/pcs/pcs_2/active_power", 100)
fimsGet("/assets/pcs/pcs_1/active_power")
fimsGet("/assets/pcs/pcs_2/active_power")

# Active Power set to 400
fimsSet("/assets/pcs/pcs_1/active_power", 400)
fimsSet("/assets/pcs/pcs_2/active_power", 400)
fimsGet("/assets/pcs/pcs_1/active_power")
fimsGet("/assets/pcs/pcs_2/active_power")

# Active Power set to 0
fimsSet("/assets/pcs/pcs_1/active_power", 0)
fimsSet("/assets/pcs/pcs_2/active_power", 0)
fimsGet("/assets/pcs/pcs_1/active_power")
fimsGet("/assets/pcs/pcs_2/active_power")

# End of Test