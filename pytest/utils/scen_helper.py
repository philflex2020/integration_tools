import os
import fnmatch
import time
import sys
import copy
from datetime import datetime
from pathlib import Path

import json
#import time
#from . import hos_helper as hos
from . import cfg_helper as cfg
#from . import rest_helper as rest
from . import general_helper as helper
from . import docker_helper as docker
from . import menu_helper as menu
#from . import ssh_helper as ssh
#from typing import NamedTuple

def setupMd(md):
    md["id"]        = os.getpid()
    md["step"]        = ""
    md["system_host"] = ""
    md["system_id"]   = "DNP3_test"
    md["system_ip"]   = ""
    md["system_path"] = "docker"
    md["scripts"]     = "/home/docker/configs/scripts"
    md["servcfg"]     = "/home/docker/configs/mb_server_test_10_3.json"
    md["clicfg"]      = "/home/docker/configs/mb_client_test_10_3.json"
    md["mbservcfg"]   = "/mb_server_test_10_3.json"
    md["mbclicfg"]    = "/mb_client_test_10_3.json"
    md["mbbase"]      = "/home/docker/configs"

    md["servcfg_tmp"] = "../configs/mb_server_tmp_10_3.json"
    md["clicfg_tmp"]  = "../configs/mb_client_tmp_10_3.json"
    md["servcfg_lcl"] = "../configs/mb_server_test_10_3.json"
    md["clicfg_lcl"]  = "../configs/mb_client_test_10_3.json"
    md["servsh"]      = "/home/docker/configs/mb_server_test_10_3.sh"
    md["logdir"]      = "/home/docker/logs"
    md["srvlog"]      = "/modbus_interface/mb_server_test_10_3.log"
    md["clilog"]      = "/modbus_interface/mb_client_test_10_3.log"
    md["fimslog"]     = "/fims_listen.log"
    md["stepset"]     = "base"
    md["scenarios"]   = {}

    scen = {}

    scen["given"]     = []

    sscen = {}
    sscen["Set up the Client"]={}
    sscen["Set up the Client"]["steps"]   = []

    sstep = {}
    sstep["kill processes"]={}
    sstep["kill processes"]["name"] = "kill processes"
    sstep["kill processes"]["run"] = False
    sstep["kill processes"]["actions"] = []
    sstep["kill processes"]["results"] = {}

    sstep["kill processes"]["actions"].append("stop modbus_client on client")
    sstep["kill processes"]["actions"].append("stop modbus_server on client")
    sstep["kill processes"]["actions"].append("stop fims_server on client")
    sstep["kill processes"]["actions"].append("stop fims_echo on client")
    sscen["Set up the Client"]["steps"].append(copy.deepcopy(sstep))

    sstep = {}
    sstep["set up configs"]={}
    sstep["set up configs"]["name"] = "set up configs"
    sstep["set up configs"]["run"] = False
    sstep["set up configs"]["actions"] = []
    sstep["set up configs"]["results"] = {}
    sstep["set up configs"]["actions"].append("load var called mb_server_test_10_3 from mb_server_test as json")
    sstep["set up configs"]["actions"].append("load var called mb_server_test_10_3_echo from mb_server_test_echo.sh as file")
    sstep["set up configs"]["actions"].append("load var called mb_client_test_10_3 from mb_client_test as json")
    sstep["set up configs"]["actions"].append("set value called connection.ip_address in mb_client_test_10_3 from config.hosts.client.system_ip saveas  mb_client_tmp") 
    sstep["set up configs"]["actions"].append("set value called connection.ip_address in mb_server_test_10_3 from config.hosts.client.system_ip_ saveas  mb_server_tmp") 
    sstep["set up configs"]["actions"].append("send var called mb_client_tmp as json to client/mb_client_test_10_3.json in client") 
    sstep["set up configs"]["actions"].append("send var called mb_server_tmp as json to client/mb_server_test_10_3.json in client") 
    sstep["set up configs"]["actions"].append("send var called mb_server_test_10_3_echo as file to client/mb_server_test_10_3_echo.sh in client") 
    sscen["Set up the Client"]["steps"].append(copy.deepcopy(sstep))

    sstep = {}
    sstep["run system"]={}
    sstep["run system"]["name"] = "run system"
    sstep["run system"]["run"] = False
    sstep["run system"]["actions"] = []
    sstep["run system"]["results"] = {}
    sstep["run system"]["actions"].append("run fims_server on client")
    sstep["run system"]["actions"].append("run fims_echo with client/mb_server_test_10_3.sh on client")
    sstep["run system"]["actions"].append("run modbus_server with client/mb_server_test_10_3 on client")
    sstep["run system"]["actions"].append("run modbus_client with client/mb_client_test_10_3 on client")

    sscen["Set up the Client"]["steps"].append(copy.deepcopy(sstep))

    scen["given"].append(copy.deepcopy(sscen))


    #scen["given"]["steps"].append(copy.deepcopy(sstep))
    # todo
    sstep = {}
    sstep["run system"]={}
    sstep["run system"]["name"] = "run system"
    sstep["run system"]["run"] = False
    sstep["run system"]["actions"] = []
    sstep["run system"]["results"] = {}
    sstep["run system"]["actions"].append("run fims_server on client")
    sstep["run system"]["actions"].append("run fims_echo with client/mb_server_test_10_3.sh on client")
    sstep["run system"]["actions"].append("run modbus_server with client/mb_server_test_10_3 on client")
    sstep["run system"]["actions"].append("run modbus_client with client/mb_client_test_10_3 on client")
    #scen["given"]["steps"].append("run modbus_server with mb_server_test")
    #scen["given"]["steps"].append(copy.deepcopy(sstep))

    md["scenarios"]["setup_system"] = copy.deepcopy(scen)


    # scen["when"]   = {}
    # scen["when"]["name"]   = "Connecting"
    # scen["when"]["steps"]   = []
    # scen["when"]["steps"].append("wait 5 seconds")
    # scen["when"]["steps"].append("find 'Connected to server' in clilog")
    # scen["when"]["steps"].append("find 'New connection' in servlog count 3")
    # scen["when"]["steps"].append("start fims_listener for 5 into fimslog")

    # scen["then"]   = {}
    # scen["then"]["name"]   = "Test Connected"
    # scen["then"]["steps"]   = []
    # scen["then"]["steps"].append("wait 5 seconds")
    # scen["then"]["steps"].append("find hs_pubs in fimslog")
    # scen["then"]["steps"].append("find ls_pubs in fimslog")

    # md["scenarios"]["setup_client"] = scen
    # scen2 = copy.deepcopy(scen)

    # scen2["given"]["name"]   = "Set up the Server"
    # scen2["given"]["steps"]   = []

    # sstep = {}
    # sstep["name"] = " set up server"
    # sstep["actions"] = []
    # sstep["actions"].append = ("use server")
    # sstep["results"] = {}
    # scen2["given"]["steps"].append(copy.deepcopy(sstep))

    # sstep["name"] = " kill tasks"
    # sstep["actions"] = []
    # sstep["actions"].append = ("pkill modbus_client")
    # sstep["actions"].append = ("pkill modbus_server")
    # sstep["actions"].append = ("pkill modbus_client")
    # sstep["actions"].append = ("pkill fims_echo")
    # sstep["actions"].append = ("pkill fims_server")
    # sstep["actions"].append = ("pkill fims_listen")
    # sstep["actions"].append = ("wait 1 second")
    # sstep["results"] = {}
    # scen2["given"]["steps"].append(copy.deepcopy(sstep))

    # sstep["name"] = " setup client configs"
    # sstep["actions"] = []
    # sstep["actions"].append = ("setip  clicfg from client")
    # sstep["actions"].append = ("setip  srvcfg from client")
    # sstep["actions"].append = ("send clicfg to client")
    # sstep["actions"].append = ("send servcfg to client")
    # sstep["actions"].append = ("wait 1 second")
    # sstep["results"] = {}
    # scen2["given"]["steps"].append(copy.deepcopy(sstep))

    # sstep["name"] = "run tasks"
    # sstep["actions"] = []
    # sstep["actions"].append = ("run fims_server on client")
    # sstep["actions"].append = ("run fims_echo on client")
    # sstep["actions"].append = ("run modbus_client with mbclicfg on server")
    # sstep["actions"].append = ("run modbus_client with mbclicfg on server")
    # sstep["actions"].append = ("wait 5 -> seconds")
    # sstep["actions"].append = ("get modbus_server logs from client")
    # sstep["actions"].append = ("get modbus_client logs from client")
    # sstep["actions"].append = ("run fims_listen for 5 -> seconds")
    # sstep["actions"].append = ("wait 6 -> seconds")
    # sstep["actions"].append = ("get fims_listen logs from client")
    # sstep["results"] = {}
    # scen2["given"]["steps"].append(copy.deepcopy(sstep))
    # md["scenarios"]["setup_server"] = copy.deepcopy(scen2)


    md["steps"]            = {}
    md["steps"]["base"]    = {}
    md["steps"]["base"]["cmds"]    = []

    md["steps"]["test"]    = {}
    md["steps"]["test"]["cmds"]    = []

    md["steps"]["test"]["cmds"].append  ("save var called v1 to v1var.json as json")
    md["steps"]["test"]["cmds"].append  ("save var called v1 to v1var.txt as text")
    md["steps"]["test"]["cmds"].append  ("load var called v1j from v1var.json as json")
    md["steps"]["test"]["cmds"].append  ("load var called v1t from v1var.txt as text")
    md["steps"]["test"]["cmds"].append  ("show vars")

    md["steps"]["test0"]    = {}
    md["steps"]["test0"]["cmds"]    = []
    md["steps"]["test0"]["cmds"].append("stop modbus_client on client")
    md["steps"]["test0"]["cmds"].append("stop modbus_server on client")
    md["steps"]["test0"]["cmds"].append("stop fims_server on client")
    md["steps"]["test0"]["cmds"].append("stop fims_echo on client")

    md["steps"]["test1"]    = {}
    md["steps"]["test1"]["cmds"]    = []
    md["steps"]["test1"]["cmds"].append  ("load var called mb_server_test_10_3 from mb_server_test.json as json")
    md["steps"]["test1"]["cmds"].append  ("load var called mb_server_test_10_3_echo from mb_server_test_10_3.sh as file")
    md["steps"]["test1"]["cmds"].append  ("load var called mb_client_test_10_3 from mb_client_test.json as json")
    md["steps"]["test1"]["cmds"].append  ("set value called connection.ip_address in mb_client_test_10_3 from config.hosts.client.system_ip saveas  mb_client_tmp") 
    md["steps"]["test1"]["cmds"].append  ("set value called system.ip_address in mb_server_test_10_3 from config.hosts.client.system_ip saveas  mb_server_tmp") 
    md["steps"]["test1"]["cmds"].append  ("send var called mb_client_tmp as json to client/mb_client_test_10_3.json on client") 
    md["steps"]["test1"]["cmds"].append  ("send var called mb_server_tmp as json to client/mb_server_test_10_3.json on client") 
    md["steps"]["test1"]["cmds"].append  ("send var called mb_server_test_10_3_echo after unescape as file to client/mb_server_test_10_3_echo.sh on client") 

    md["steps"]["test2"]    = {}
    md["steps"]["test2"]["cmds"]    = []
    md["steps"]["test2"]["cmds"].append("run fims_server on client")
    md["steps"]["test2"]["cmds"].append("run client/mb_server_test_10_3_echo.sh on client type script logs echo")
    md["steps"]["test2"]["cmds"].append("run modbus_server with client/mb_server_test_10_3.json on client")
    md["steps"]["test2"]["cmds"].append("run modbus_client with client/mb_client_test_10_3.json on client")

    md["steps"]["test3"]    = {}
    md["steps"]["test3"]["cmds"]    = []
    md["steps"]["test3"]["cmds"].append("run fims_listen for 5 logs listen_01 on client")
    md["steps"]["test3"]["cmds"].append("wait 5 seconds")
    md["steps"]["test3"]["cmds"].append("log listen_01 from listen_01 on client saveas fims_listen_01")
    md["steps"]["test3"]["cmds"].append("find pub from fims_listen_01 saveas fims_listen_02_pub after 1")
    md["steps"]["test3"]["cmds"].append("find comp2 from fims_listen_02_pub saveas fims_listen_temp countinto comp2_count" )
    md["steps"]["test3"]["cmds"].append("find comp1 from fims_listen_02_pub saveas fims_listen_temp countinto comp1_count" )

    md["steps"]["test4"]    = {}
    md["steps"]["test4"]["cmds"]    = []
    md["steps"]["test4"]["cmds"].append("av var1 1234 float")
    md["steps"]["test4"]["cmds"].append("av var2 123 float")
    md["steps"]["test4"]["cmds"].append("av ans OK")
    md["steps"]["test4"]["cmds"].append("show vars")
    md["steps"]["test4"]["cmds"].append("if var2 < var1 then myval = ans")
    md["steps"]["test4"]["cmds"].append("show vars")

    md["steps"]["test5"]    = {}
    md["steps"]["test5"]["cmds"]    = []
    md["steps"]["test5"]["cmds"].append("av var1 34 float")
    md["steps"]["test5"]["cmds"].append("av var2 24 float")
    md["steps"]["test5"]["cmds"].append("av var4 3456 float")
    md["steps"]["test5"]["cmds"].append("if var1 > var2 then var3 = var4 else var2 = altvar4")
    md["steps"]["test5"]["cmds"].append("show vars")
    md["steps"]["test5"]["cmds"].append("if var1 < var2 then var3 = var4 else var3 = altvar4")
    md["steps"]["test5"]["cmds"].append("av altvar4 9999 float")
    md["steps"]["test5"]["cmds"].append("if var1 < var2 then var3 = var4 else var3 = altvar4")
    md["steps"]["test5"]["cmds"].append("show vars")

    md["steps"]["test6"]    = {}
    md["steps"]["test6"]["cmds"]    = []
    md["steps"]["test6"]["cmds"].append("stop fims_listen")
    md["steps"]["test6"]["cmds"].append("stop fims_server")
    md["steps"]["test6"]["cmds"].append("ps")
    md["steps"]["test6"]["cmds"].append("run fims_server")
    md["steps"]["test6"]["cmds"].append("run fims_listen")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval from 99")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval2 from myval2")
    md["steps"]["test6"]["cmds"].append("av fff 55 float")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval3 from fff")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval3 from -1 format single")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval3 from -1 format naked")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval3 from -1 format clothed")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval3 from true format single")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval3 from true format naked")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval3 from true format clothed")
    md["steps"]["test6"]["cmds"].append("set uri called /components/pcs id myval4 from '\"this is myval4\"'")
    md["steps"]["test6"]["cmds"].append("stop fims_listen")
    md["steps"]["test6"]["cmds"].append("log fims_listen")

    
    md["steps"]["test7"]    = {}
    md["steps"]["test7"]["cmds"]    = []
    md["steps"]["test7"]["cmds"].append("add scenario called myscenario phase given op 'this is the given op' steps 'some name' from base")    
    md["steps"]["test7"]["cmds"].append("add scenario called myscenario phase given op 'this is the given op' steps 'some name' from base")    
    md["steps"]["test7"]["cmds"].append("add scenario called myscenario phase when op 'this is the when op' steps 'start when' from base")    
    md["steps"]["test7"]["cmds"].append("add scenario called myscenario phase then op 'this is the then op' steps 'start when' from base")    
    md["steps"]["test7"]["cmds"].append("showscn")

    md["steps"]["init"]    = {}
    md["steps"]["init"]["cmds"]    = []
    md["steps"]["init"]["cmds"].append  ("setHost DNP3_server as server")
    md["steps"]["init"]["cmds"].append  ("setHost DNP3_test as test")
    md["steps"]["init"]["cmds"].append  ("setHost DNP3_client as client")

    md["hosts"]              = {}
    md["varlists"]           = {}
    md["vars"]            = {}
    md["vars"]["v1"]      = "/components/comp2/24_decode_id"
    md["vars"]["v2"]      = "/components/comp1/01"
    md["vars"]["v3"]      = "/components/comp1/02"

    md["varlists"]["base"]   = copy.deepcopy(md["vars"])
    md["vars"] = md["varlists"]["base"]

    md["hosts"]["client"] = {}
    md["hosts"]["server"] = {}
    md["hosts"]["client"]["system_id"] = "DNP3_test"
    md["hosts"]["client"]["system_host"] = ""
    md["hosts"]["client"]["ip_address"] = ""
    md["hosts"]["client"]["path"] = "docker"
    md["hosts"]["server"]["system_id"] = "DNP3_server"
    md["hosts"]["server"]["system_host"] = ""
    md["hosts"]["server"]["ip_address"] = ""
    md["hosts"]["server"]["path"] = "docker"






def createSScen(name):
    sscen = {}
    sscen[name] = {}
    sscen[name]["steps"]=[]
    sstep = createSStep("run system")
    sscen[name]["steps"].append(copy.deepcopy(sstep))
    return sscen

def createSStep(name):
    sstep = {}
    sstep[name]={}
    sstep[name]["name"] = name
    sstep[name]["run"] = False
    sstep[name]["actions"] = []
    sstep[name]["results"] = {}
    sstep[name]["actions"].append("this is a test action")
    return sstep


def UseNamedObj(md,obj,cname,fAdd):
    if obj not in md:
        md[obj]={}
    if cname in md[obj]:
        sys.stdout.write(" Use [{}] [{}]  found \n".format(obj, cname))
        return md[obj][cname]
    if fAdd:
        md[obj][cname]={}
        return md[obj][cname]        
    return None

def UseDictObj(md,cname,fAdd):
    if cname in md:
        sys.stdout.write(" Use [{}] found \n".format(cname))
        return md[cname]
    if fAdd:
        md[cname]={}
        return md[cname]        
    return None

# item:cname[]
def UseArrayObj(md,cname,fAdd):
    if cname in md:
        sys.stdout.write(" Use [{}] found \n".format(cname))
        return md[cname]
    if fAdd:
        md[cname]=[]
        return md[cname]        
    return None
# item:[
#   { "cfield"::cname}
# ]
def UseItemInArray(md,cfield, cname,fAdd):
    for xx in md:
        if cfield in xx:
            if xx[cfield] == cname:

                sys.stdout.write(" Use [{}] found \n".format(cname))
                return xx
    if fAdd:
        xx = {}
        xx[cfield]=cname
        md.append(xx)
        return xx        
    return None

# [
#    { cname1:{}},
#    { cname2:{}},
#    { cname3:{}}
# ]
#  
def UseObjInArray(md,cname,fAdd):
    for xx in md:
        if cname in xx.keys():
            sys.stdout.write(" Use [{}] found \n".format(cname))
            return xx[cname]
    sys.stdout.write(" UseObj adding  [{}] \n".format(cname))
    if fAdd:
        xx = {}
        xx[cname]={}
        md.append(xx)
        return xx[cname]        
    return None


###### probably all deprecated
# add scenario called fooo 
# add scenario called setup_system id given name 'Set up the Client' step 'kill processes' 
def AddScenario(md,cmds):
    cdict = menu.myDict(cmds)
    cwhat = cdict["add"]
    if cwhat == "scenario":
        if "called" in cdict:
            ccalled = cdict["called"]
        if ccalled in md["scenarios"]:
            sys.stdout.write(" Add scenario [{}]  found \n".format(ccalled))
        else:
            sys.stdout.write(" Add scenario [{}] Not found, creating it \n".format(ccalled))
            scen = {}
            scen["given"]    = []
            scen["when"]     = []
            scen["then"]     = []
            md["scenarios"][ccalled] = copy.deepcopy(scen)
            #return []

        scen = md["scenarios"][ccalled]
        if "id" in cdict:
            cid = cdict["id"]
        if cid in scen:
            sys.stdout.write(" Add scenario id[{}]  found \n".format(cid))
        else:
            sys.stdout.write(" Add scenario id [{}] Not found,  building it  \n".format(cid))
            return []
        scid = md["scenarios"][ccalled][cid]
        if "name" in cdict:
            cname = cdict["name"]
            if cname[0] == "'":
                cname=cname[1:-1]
        else:
            sys.stdout.write(" Add scenario \"name\" Not found in command \n")
            return []

        if cname in scid:
            sys.stdout.write(" Add scenario id [{}] name [{}] found \n".format(cid,cname))
        else:
            sys.stdout.write(" Add scenario id [{}] name [{}] created \n".format(cid,cname))
            sscen = createSScen(cname)
            scid.append(copy.deepcopy(sscen))
        sscen = md["scenarios"][ccalled][cid][cname]
        if "step" in cdict:
            cstep = cdict["step"]
        else:
            sys.stdout.write(" Add scenario \"step\" Not found in command \n")
            return []

        sstep = createSStep(cstep)
        sscen[cname]["steps"].append(copy.deepcopy(sstep))
    return []

def MakeScenario(md,cmds):
    cdict = menu.myDict(cmds)
    cwhat = cdict["use"]
    if cwhat == "scenario":
        if "ok" in cdict:
            cok = cdict["ok"]
        else:
            cok = "ask"
        if "called" in cdict:
            ccalled = cdict["called"]
            if ccalled in md["scenarios"]:
                sys.stdout.write(" Make scenario [{}]  found \n".format(ccalled))
            else:
                if cok == "ask":
                    sys.stdout.write(" No scenario [{}]  found  create it ? : (y/n)".format(ccalled))
                    sys.stdout.flush()
                    line = sys.stdin.readline()
                    if len(line) and line[0] == "y":
                        cok = "ok"

                if cok == "ok":
                    sys.stdout.write(" Creating scenario [{}]  \n".format(ccalled))
                    scen = {}
                    scen["given"]    = []
                    scen["when"]     = []
                    scen["then"]     = []

                    sscen = createSScen("Start")
                    scen["given"].append(copy.deepcopy(sscen))
                    md["scenarios"][ccalled] = copy.deepcopy(scen)

    return []

