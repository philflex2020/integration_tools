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
#from . import ssh_helper as ssh
#from typing import NamedTuple
from . import scen_helper as Scen

md ={}



#log = logging.getLogger(__name__)
menu_list = []
menu_cfg = []
menu_file="*.json"
menu_dir="menu"

def showMenu(md):
    print (" -------------------------------------------------------------------------------")
    print (" FlexGen Gherkin Pickler  host  [{}] id [{}] docker [{}]".format(md["system_name"],md["system_host"],md["system_id"]))
    print (" -------------------------------------------------------------------------------")
    print (" (h)elp                    :- show menu")
    print (" basic commands ------------------(cmd) -help  for more info -------------------")
    print (" run                       :- run something on a host with args and / or configs")
    print (" stop                      :- stop something on a host based on name or pid")
    print (" log                       :- get a log file ")
    print (" use (sname) called (name) :- switch target host")
    print (" ps                        :- show processes on a host")
    print (" top                       :- show processes on a host")
    print (" get                       :- get something from a host  file json uri")
    print (" set                       :- set something on a host  file json uri")
    print (" show xx [called yy]       :- config|scenarios|steps|hosts|vars")
    #print ()
    print (" other commands -----------------------------------------------------------------")
    #print ()
    print (" runsteps name              :- run a series of commands from a list of steps")
    print (" av <vname> <value> <type>  :- set a variable <name> to a value as a type")
    print (" find <string> from <vname>  saveas <rvname> countinto <countvar")
    print (" wait <time in secs> seconds")
    print (" if var1 > var2 then var3 = var4 else var2 = altvar4")
    print (" load xx [called yy] from fname   :- config|scenarios|steps from file")
    print (" send xx [called yy] from fname   :- config|scenarios|steps from file")
    print (" save xx [called yy] in fname     :- config|scenarios|steps into file")
    print (" setHost (name)                   :- set docker host info ( container must be running)")
    print (" pkill (name)                     :- kill processes on host")
    print (" (q)uit                           :- exit")
    print ()

def execRes(dock,cmd):
    sys.stdout.write(" running {}\n".format(cmd))
    res = docker.exec_in(dock, cmd)
    for x in  range(len(res)):
        sys.stdout.write("{}\n".format(res[x]))

def xrunSteps(md, base):
    try:
        for icmd in md["steps"][base]["cmds"]:
            sys.stdout.write("runsteps {} step [{}]\n".format(base, icmd))
            runCmd(md, icmd)
            sys.stdout.write("======\n\n")
    except:
        sys.stdout.write("steps {} not found\n".format(base))

def useSteps(md, base):
    md["stepset"] = base
    try:
        slen = len(md["steps"][base]["cmds"])
    except:
        sys.stdout.write("steps {} created\n".format(base))
        md["steps"][base] = {}
        md["steps"][base]["cmds"] = []


# add scenario called myscenario [phase given[ op 'this is the first op' [ steps 'some name' from base] ]]
# add scenario called myscenario description 'demo scenario' phase given op 'this is the first op' steps 'some name' from base

def fixUpString(str):
    if len(str) > 0:
        if str[0] == "'":
            str=str[1:-1]
    return str

# add scenario called myscenario description 'demo scenario' phase given op 'this is the first op' steps 'some name' from base
# add cmd as 'run some shit' to scenarios.myscenario.given.'this is the first op'.'some name' 
def runAddF(md,cmds,fAdd):
    #fAdd = True
    cdict = myDict(cmds)
    obj = None
    if "called" in cdict:
        ccalled = cdict["called"]
    cdesc = None
    if "description" in cdict:
        cdesc= cdict["description"]
    if "add" in cdict:
        cwhat = cdict["add"]
    elif "seek" in cdict:
        cwhat = cdict["seek"]
    else:
        sys.stdout.write(" runAddF only works with add or seek  not   [{}] \n".format(cmds[0]))
        return []

    try:
        #cwhat = cdict["add"]
        if cwhat == "scenario":
            sys.stdout.write(" UseScenario    [{}] \n".format(ccalled))
            obj = Scen.UseNamedObj(md, cwhat+"s", ccalled, fAdd)
            if obj == None:
                sys.stdout.write("Error  in UseNamed [{}]   \n".format(cdict))
            else:
                if cdesc:
                    obj["desc"] = fixUpString (cdesc) 
                #return []
    except:
        sys.stdout.write("Error  in Add [{}]   \n".format(cdict))

    try:
        cphase = cdict["phase"]
        obj = Scen.UseArrayObj(obj, cphase, fAdd)
    except:
        sys.stdout.write("Error  in Phase  [{}]   \n".format(cdict))

    sys.stdout.write("==> Phase  [{}] Ok  \n".format(cphase))

    try:
        cop = cdict["op"]
        obj = Scen.UseObjInArray(obj, fixUpString(cop), fAdd)
    except:
        sys.stdout.write("Error  in Phase [{}] op  [{}]   \n".format(cphase,cop))
    
    obj = Scen.UseArrayObj(obj, "steps", fAdd)

    try:
        csteps = fixUpString(cdict["steps"])
        # if fAdd is false and sobj is None we did not find the steps.
        sobj = Scen.UseObjInArray(obj, csteps, fAdd)

        sobj["run"] = False
        Scen.UseArrayObj(sobj, "cmds", fAdd)
        Scen.UseArrayObj(sobj, "results", fAdd)

    except:
        sys.stdout.write("Error  in Phase [{}] steps  [{}]   \n".format(cphase,csteps))

    if not fAdd:
        return []
 
    if "from" not in cdict:
        sys.stdout.write(" OK stopping at from Phase [{}] steps  [{}]   \n".format(cphase,csteps))
        md["steps"][csteps] = sobj
        return []

    try:
        cfrom = cdict["from"]
        if cfrom in md["steps"]:
            #sys.stdout.write("Setup  in steps [{}] from  [{}]   \n".format(csteps, cfrom))
            sxobj = copy.deepcopy(md["steps"][cfrom])
            #sys.stdout.write(" New steps [{}] from  [{}]   \n".format(sxobj, cfrom))

            sobj["cmds"] = sxobj["cmds"]
    except:
        sys.stdout.write("Error  in steps [{}]   \n".format(csteps))
    

    return []

# add scenario called myscenario description 'demo scenario' phase given op 'this is the first op' steps 'some name' from base
# add cmd as 'run some shit' to scenarios.myscenario.given.'this is the first op'.'some name' 
def runAdd(md,cmds):
    return runAddF(md,cmds,True)

# seek scenario called myscenario description 'demo scenario' phase given op 'this is the first op' steps 'some name' from base
def runSeek(md,cmds):
    return runAddF(md,cmds,False)

def runUseHelp(md,cmds):

    sys.stdout.write("use client\n")
    sys.stdout.write("use host called client\n")

    sys.stdout.write("use scenario called setup_system id given name 'Set up the Client' step 'kill processes' \n")
    sys.stdout.write("use vars from <varlistname>\n") 

def runUse(md,cmds):
    try:
        if cmds[1] == "-help":
            runUseHelp(md,cmds)
            return []
    except:
        pass
    cdict = myDict(cmds)
    ccalled = cdict["use"]
    try:
        cwhat = cdict["use"]
        if "called" in cdict:
            ccalled = cdict["called"]
        sys.stdout.write(" Use [{}] called  [{}] \n".format(cwhat,ccalled))
        if cwhat == "vars":
            try:
                cfrom = cdict["from"]
                if "varlists" not in md.keys():
                    md["varlists"] = {}
                if cfrom not in md["varlists"].keys():
                    md["varlists"][cfrom] = {}
                md["vars"] =  md["varlists"][cfrom] 
                sys.stdout.write(" vars switched to  [{}] \n".format(cfrom))
            except:
                sys.stdout.write("unable to switch vars [{}] \n".format(cdict))
                
            return []
        
        if cwhat == "host" or ccalled in md["hosts"]:
            xxmd = md["hosts"][ccalled]
            md["system_host"] = xxmd["system_host"]
            md["system_id"] = xxmd["system_id"]
            md["system_ip"] = xxmd["system_ip"]
            md["system_name"] = xxmd["system_name"]
        elif cwhat == "scenario" and ccalled not in md["scenarios"]:
            sys.stdout.write(" MakeScenario running   [{}] \n".format(ccalled))
            Scen.MakeScenario(md,cmds)
            return []
        elif cwhat == "scenario" and ccalled in md["scenarios"]:
            sys.stdout.write(" Use scenario [{}]  found \n".format(ccalled))
            xxmd = md["scenarios"][ccalled]
            md["scen"] = xxmd
            if "id" in cdict:
                cid = cdict["id"]
                # pick up "given"
                sys.stdout.write(" Use scenario id  [{}]  found \n".format(cid))
                md["scen_id"] = xxmd[cid]
                if "name" in cdict:
                    cname = cdict["name"]
                    if cname[0]=="'":
                        cname=cname[1:-1]
                    sys.stdout.write(" looking for  name [{}]  found \n".format(cname))
                if "step" in cdict:
                    cstep = cdict["step"]
                    md["scen_steps"] = {}

                    if cstep[0]=="'":
                        cstep=cstep[1:-1]
                    sys.stdout.write(" looking for  step [{}]  found \n".format(cstep))

                # scen_id is an array of objects  
                for xx in xxmd[cid]:
                    #sys.stdout.write("\n Use scen_id xx  [{}]  \n".format(xx))

                    if cname in xx.keys():
                        # found the name of the given system now find the steps
                        xxx = xx[cname]
                        #sys.stdout.write(" \n found xxx [{}]  [{}]  \n".format(cname, xxx))
                        xsteps = xxx["steps"]

                        # xsteps is an array of objects  
                        for xstep in xsteps:
                            if cstep in xstep.keys():
                                # found the name of the given system now find the steps
                                xxs = xstep[cstep]
                                md["scen_steps"] = xxs
                                sys.stdout.write(" \n found steps  [{}]  \n".format(xxs))
                                sys.stdout.write(" now use \"runsteps actions\" to edit/run them   \n")





    except:
        sys.stdout.write(" host [{}] not found \n".format(cmds[1]))

# runSteps(md,"init")
def runSteps(md,cmds):
    sys.stdout.write(" runSteps in progress \n")
    try:
        if cmds[1] in md["steps"]:
            sys.stdout.write(" doing runSteps cmds[1]\n")
            xrunSteps(md, cmds[1])
            return []
    except:
        pass
    try:
        acts = md["scen_steps"]["actions"]
    except:
        sys.stdout.write(" no actions found \n")
        return []

    sys.stdout.write(" runSteps  found actions \n")
    try:  
        ix = 0
        # ary.append(ary[len(ary) - 1]) 
        # x = len(ary) - 1
        # while x >= pos:
        #     ary[x] = ary[x - 1]
        #     x -= 1
        # ary[pos - 1] = val
        while ix < len(acts):
            sys.stdout.write(" run act [{}] : (y/n/q/i)".format(acts[ix]))
            sys.stdout.flush()
            line = sys.stdin.readline()
            #sys.stdout.write("line {}\n".format(line))

            if len(line)> 1:
                if (line[0] == 'y' or line[0] == "Y"):
                    runCmd(md, acts[ix])
                    sys.stdout.write(" ran act [{}]\n\n".format(acts[ix]))

                elif (line[0] == 'n' or line[0] == "N"):
                    sys.stdout.write(" skipped act [{}]\n\n".format(acts[ix]))

                elif (line[0] == 'd' or line[0] == "D"):
                    sys.stdout.write(" deleted act [{}]\n\n".format(acts[ix]))
                    acts.pop(ix)

                elif (line[0] == 's' or line[0] == "S"):
                    x = 0
                    while x < len(acts):
                        if x == ix:
                            xp = "=>"
                        else:
                            xp = "  "
                        sys.stdout.write("{} [{}] [{}]\n".format(xp, x,acts[x]))
                        x +=  1

                elif (line[0] == 'i' or line[0] == "I"):
                    sys.stdout.write(" insert new act \n")
                    newact = sys.stdin.readline()
                    acts.append(acts[len(acts) - 1]) 
                    x = len(acts) - 1
                    while x > ix:
                        acts[x] = acts[x - 1]
                        x -= 1
                    acts[ix] = newact

                elif (line[0] == 'e' or line[0] == "E"):
                    sys.stdout.write(" type replacement act \n")
                    newact = sys.stdin.readline()
                    acts[ix] = newact
                    ix = ix -1

            ix = ix + 1
    except:
        sys.stdout.write(" no actions found \n")

#setip  clicfg from client")
# TODO move it to the dest
# helper.upload_file(local_path, remote_path, connect_info):
# deprecated
def runSetip(md,cmds):
    try:
        fname=md[cmds[1]+"_lcl"]
        fwname=md[cmds[1]+"_tmp"]
        print("setIp in file  [{}] to [{}]".format(fname, md["hosts"][cmds[3]]["system_ip"]))
        mbcfg = helper.read_json(fname)
        mbcfg["connection"]["ip_address"] = md["hosts"][cmds[3]]["system_ip"]
        helper.write_json(mbcfg, fwname)
    except:
        print("setIp cmds not understood")

#run modbus_server with mbservcfg in client
def getCvalue(md,cdict,var):
    try:
        cname = cdict[var]
        if cname[0] == "'":
            cname=cname[1:-1]
            return cname
        try:
            cv = float(cname)
            return cv
        except:
            pass
    except:
        pass
    cname = cdict[var]
    if cname in md["vars"]:
        cv = md["vars"][cname]
        return cv
    else:
        return cname
    return None

def getChost(md,cdict):
    cin = md["system_name"] 
    if "in" in cdict:
        cin=cdict["in"]
    if "on" in cdict:
        cin=cdict["on"]
    chost = md["system_host"]
    try:
        xxmd = md["hosts"][cin]
        chost = xxmd["system_host"]
        cname = xxmd["system_name"]
    except:
        sys.stdout.write("Run Error unable to select chosen host {}\n".format(cin))
        return ()
    return (chost,cin,cname)

def runHost(chost,cmd):
    res = []
    resa = docker.exec_in(chost, cmd)
    print("res = [{}]\n".format(res) )
    for x in resa:
        res.append(x)
    return res

def runCopyTo(chost,fwname,remote_path):
    res = []
    docker.copy_to(chost, fwname, remote_path)
    return res
def runCopyFrom(chost,fwname,remote_path):
    res = []
    docker.copy_from(chost, fwname, remote_path)
    return res

#run modbus_server with mbservcfg on client
#run client/mb_server_test_10_3.sh type script logs echo on client
# Done use con selected host for runRun 
# given a log file we can get the pid of the writer
#     lsof | grep fs.log | head -1 | cut -d ' ' -f2

def runRunHelp(md,cmds):
    sys.stdout.write("\trun - help\n")
    sys.stdout.write("\trun  a designated task on the selected host\n")
    sys.stdout.write("\trun fims_server ( uses default host) \n")
    sys.stdout.write("\trun fims_server on <client>   -- designate the host to use \n")
    sys.stdout.write("\trun fims_server on <client> for 5   -- use a 5 second timeout \n")
    sys.stdout.write("\trun fims_server with <config_file> on <client>\n")
    sys.stdout.write("\trun fims_server logs <log_file> on <client>\n")
    sys.stdout.write("\trun fims_server args 'special args' on <client>\n")
    sys.stdout.write("\trun fims_server type <exec|script> on <client> -- run an executable or a script\n")
    sys.stdout.write("\trun steps called 'some name'\n")


def runRun(md,cmds):
    cdict = myDict(cmds)
    if cmds[1] == "-help":
        runRunHelp(md,cmds)
        return []
    if cmds[1] == "steps":
        if "called" in cdict:
            ccalled = fixUpString(cdict["called"])
            sys.stdout.write("\trun steps called {}\n".format(ccalled))
            if ccalled in md["steps"]:
                sys.stdout.write("\tfound steps called {}\n".format(ccalled))
        return []


    if "with" in cdict:
        cwith=cdict["with"]
    else:
        cwith = ""
    cfor = "0"
    if "for" in cdict:
        cfor = cdict["for"]
    ctype = "exec"
    if "type" in cdict:
        ctype = cdict["type"]
    clogs = "default"
    if "logs" in cdict:
        clogs = cdict["logs"]
    cargs = ""
    if "args" in cdict:
        cargs = cdict["args"]
        if cargs[0] == "'":
            cargs=cargs[1:-1]
    try:
        chosta = getChost(md,cdict)
        chost = chosta[0]
        cin = chosta[1]
        cname = chosta[2]
    except:
        sys.stdout.write(" runRun unable to decode chost from {}\n".format(cdict)) 
        return []
    try:
        print(" runRun fcn =[{}] cfg = [{}] dir = [{}] cname [{}] ctype [{}]\n".format(cdict["run"],cwith,cin, cname, ctype)) 
        cconfigs="/home/docker/configs"
        cxlogs="/home/docker/configs/{}/logs".format(cin)
        logcmd = "sh -c \"mkdir -p  {}\"".format(cxlogs)
        try:
            runHost(chost,logcmd)
        except:
            print(" runRun not able to make log dir")
  
        #cdir = md["mbbase"]
        if cfor != "0":
            ctimeout = "timeout {}".format(cfor)
        else:
            ctimeout = ""            
        if ctype == "exec":
            if clogs == "default":
                clogname = cdict["run"]
            else:
                clogname = clogs
            if cwith != "":
                cmd = "sh -c \"{} /usr/local/bin/{} {}/{} >{}/{}.log 2>&1&\"".format(ctimeout, cdict["run"], cconfigs, cwith, cxlogs, clogname)
            else:
                cmd = "sh -c \"{} /usr/local/bin/{} {} >{}/{}.log 2>&1&\"".format(ctimeout, cdict["run"], cargs, cxlogs, clogname)
            print("cmd exec = [{}]\n".format(cmd) )
        elif ctype == "script":
            #print("runRun getting cmd script \n" )

            cmd = "sh -c \"sh /home/docker/configs/{} {} >{}/{}.log 2>&1&\"".format(cdict["run"], cargs, cxlogs, clogs)
            #print("cmd script = [{}]\n".format(cmd) )
    except: 
        pass
    try:
       #                        0 modbus_server /home/docker/configs/client/ 
        runHost(chost,cmd)
    except:
        print(" run not understood")
    # try:
    #     cmd = "cat {}/{}.log ".format(cxlogs, clogname)
    #     res = runHost(chost, cmd)
    #     print("chost [{}] cmd [{}] res = [{}]\n".format(chost,cmd, res) )
    # except:
    #     print(" runRun log  understood")
 
# wait 5 seconds
def runWait(md,cmds):
    #cdict = myDict(cmds)
    wtime=float(cmds[1])
    time.sleep(wtime)
    return []

def runStopHelp(md,cmds):
    sys.stdout.write("\tstop - help\n")
    sys.stdout.write("\tstop  a designated task on the selected host\n")
    sys.stdout.write("\tstop fims_server ( uses default host) \n")
    sys.stdout.write("\tstop fims_server on <client>\n")

#stop modbus_server on client
#stop 246 on client
def runStop(md,cmds):
    if cmds[1] == "-help":
        runStopHelp(md,cmds)
        return []

    cdict = myDict(cmds)
    try:
        chosta = getChost(md,cdict)
        chost = chosta[0]
        #cin = chosta[1]
        #cname = chosta[2]
    except:
        sys.stdout.write(" runStop unable to decode chost from {}\n".format(cdict)) 
        return []
 
    cstop = cdict["stop"]
    cmd="pkill  {} ".format(cstop)
    try:
        if cstop.isnumeric():
            cmd="kill  {} ".format(cstop)
    except:
        print(" runStop error in {}".format(cstop))
    
    print("host [{}] cmd = [{}]\n".format(chost, cmd) )

    try:
        runHost(chost,cmd)
    except:
        print(" runStop not understood")

def runLogHelp(md,cmds):
    sys.stdout.write("log - help\n")
    sys.stdout.write(" get a named log file from a host [and save it into a var]\n")
    sys.stdout.write("\tlog logname \n")
    sys.stdout.write("\tlog logname in <host>\n")
    sys.stdout.write("\tlog <var> from logname in <host>\n")
    sys.stdout.write("\tlog logname into <var> in <host>\n")
#log modbus_server with mbservcfg in client to|into <somevar>
#log modbus_server from mb_server_test in client to|into <somevar>
#log data from mb_server_test in client saveas <somevar>

def runLog(md,cmds):
    cdict = myDict(cmds)
    if cmds[1] == "-help":
        runLogHelp(md,cmds)
        return []

    cvar = cdict["log"]
    cfrom = cvar
    cin = md["system_name"]
    try:
        chosta = getChost(md,cdict)
        chost = chosta[0]
        #cin = chosta[1]
        #cname = chosta[2]
    except:
        sys.stdout.write(" runLog unable to decode chost from {}\n".format(cdict)) 
        return []
    res = []

    try:
        #cwith = md[cdict["with"]]
        if "from" in cdict:
            cfrom = cdict["from"]
        if "saveas" in cdict:
            cvar = cdict["saveas"]

        print("fcn =[{}] cfg = [{}] dir = [{}]\n".format(cdict["log"],cfrom,cin)) 
        cmd="cat /home/docker/configs/{}/logs/{}.log".format(cin, cfrom)
        print("cmd = [{}]\n".format(cmd) )
        # use in to snag client
        res = runHost(chost,cmd)
        for x in  range(len(res)):
            sys.stdout.write("{}\n".format(res[x]))
        try:
            cinto = cdict["into"]
        except:
            cinto = cvar
        if len(cvar) > 0:
            md["vars"][cinto] = res
        print(" runLog completed OK")

    except:
        print(" runLog not understood")
    return res

#save steps called base to somename (as json)
#save var called myvar to somename (as json)
#steps scenarios
def runSave(md,cmds):
    cdict = myDict(cmds)
    ccalled=""
    cas="json"
    cto = ""
    res = []
    if "called" in cdict:
        ccalled = cdict["called"]
    if "as" in cdict:
        cas = cdict["as"]
    if "to" in cdict:
        cto = cdict["to"]
    cwhat = cdict["save"]
    quit = 0
    fname = "configs/{}_{}".format(cwhat,cto)
    if cwhat in ["steps","scenarios","hosts","config","var"]:
        try:
            if cwhat == "var":
                fmd = md["vars"][ccalled]
            elif cwhat == "config":
                fmd = md
            else:
                fmd = md[cwhat][ccalled]
            if cas == "json":
                helper.write_json(fmd, fname)
            else:
                helper.write(fmd, fname)
            sys.stdout.write("save  {} called [{}]  written to [{}] as [{}] \n".format(cwhat, ccalled, fname, cas))
        except:
            sys.stdout.write("Save Error saving  {} called [{}] to [{}] \n".format(cwhat, ccalled, fname))
    return res

# load steps called base from somname
# save steps called base as somname
#steps scenarios
# load var called mb_server_test_10_3 from mb_server_test
def runLoad(md,cmds):
    cdict = myDict(cmds)
    res = []
    ccalled = ""
    try:
        cwhat = cdict["load"]
        cfrom = cdict["from"]
    except:
            sys.stdout.write("Load Error cdict {} \n".format(cdict))
            return res
    if "called" in cdict:
        ccalled = cdict["called"]
    quit = 0
    fname = "configs/{}_{}".format(cwhat,cfrom)
    if cwhat in ["steps","scenarios","hosts","config","var"]:
        try:            
            if cwhat == "config":
                mdx = helper.read_json(fname)
                sys.stdout.write("load  {} read from [{}] \n".format(cwhat, fname))
                json_string = json.dumps(mdx,indent=4)
                sys.stdout.write(" read [{}] \n".format(json_string))
            elif cwhat == "var" and ccalled != "":
                try:
                    cas = cdict["as"]
                except:
                    cas = "json"
                if cas == "json":
                    mdx = helper.read_json(fname)
                else:
                    mdx = helper.read(fname)

                sys.stdout.write("load  {} read from [{}] \n".format(cwhat, fname))
                #json_string = json.dumps(mdx,indent=4)
                #sys.stdout.write(" read [{}] \n".format(json_string))
                md["vars"][ccalled] = mdx

            elif ccalled != "":       
                mdx = helper.read_json(md[cwhat][ccalled],fname)
                md[cwhat][ccalled] = mdx
                sys.stdout.write("load  {} called [{}]  read from [{}] \n".format(cwhat, ccalled, fname))
        except:
            sys.stdout.write("Load Error loading {} called [{}] from [{}] \n".format(cwhat, ccalled, fname))
    return res

def runShowHelp(md,cmds):
    sys.stdout.write("show  hosts\n")
    sys.stdout.write("show  vars\n")
    sys.stdout.write("show  steps\n")
    sys.stdout.write("show  scenarios|scn\n")
    sys.stdout.write("show  config|cfg\n")

def runShow(md,cmds):
    try:
        if cmds[1] == "-help":
            runShowHelp(md,cmds)
            return []
    except:
        pass
    cdict = myDict(cmds)
    ccalled=""
    res = []
    if "called" in cdict:
        ccalled = cdict["called"]
    cwhat = cdict["show"]
    quit = 0
    if cwhat in ["steps","scenarios","hosts","config","cfg","scn","vars"]:
        try:
            if cwhat == "cfg":
                cwhat = "config"            
            elif cwhat == "scn":
                cwhat = "scenarios"            
            if cwhat == "config":
                mdx = json.dumps(md,indent=4)
                sys.stdout.write(" show [{}] \n".format(mdx))
            else:       
                if ccalled == "" :
                    mdx = json.dumps(md[cwhat],indent=4)
                    sys.stdout.write("show  {} [{}] \n".format(cwhat, mdx))
                else:
                    if ccalled not in md[cwhat]:
                        sys.stdout.write("error show  {} called [{}] notfound  \n".format(cwhat, ccalled))
                        return []

                    mdx = json.dumps(md[cwhat][ccalled],indent=4)
                    sys.stdout.write("show  {} called [{}]  [{}] \n".format(cwhat, ccalled, mdx))
        except:
            sys.stdout.write("Show Error for {} called [{}] \n".format(cwhat, ccalled))
    return res

def UnEscape(mdat):
    print ("Unescape")

    mdat.replace("\\\"",'\"')
    mdat.replace("\\n",'\n')
    print ("Unescape done")
    #print (mdat)
    return mdat[1:-1]
# def copy_to(docker_id, local_path, remote_path):
#     log.debug("Copy local file '{}' to the docker {}.".format(local_path, docker_id))
#     cmd = "docker cp {} {}:/{}".format(local_path, docker_id, remote_path)
#     response = _execute_cmd(cmd)
#     return response
#send var called mb_client_tmp as json to client/mb_client_test_10_3.json in client
#send var called mb_server_echo_sh as file after unescape to client/mb_server_echo_10_3.sh in client
def runSend(md,cmds):
    res = []
    cdict = myDict(cmds)
    try:
        cwhat      = cdict["send"]
        ccalled    = cdict["called"]
        cas        = cdict["as"]
        cto        = cdict["to"]
        if "on" in cdict:
            cin=cdict["on"]
        if "in" in cdict:
            cin=cdict["in"]

        cafter = ""
        if "after" in cdict:
            cafter = cdict["after"]
        mdat       = md["vars"][ccalled]
        docker_id  = md["hosts"][cin]["system_host"]
    except:
        sys.stdout.write("Send failed getting vars[{}] \n".format(cdict))
        return []

    try:
        if cwhat == "var":
            if ccalled in md["vars"]:
                if cas == "json":
                    fwname = "configs/var_{}.json".format(ccalled)
                    helper.write_json(mdat, fwname)
                    remote_path = "home/docker/configs/{}".format(cto)
                    runCopyTo(docker_id, fwname, remote_path)
                elif cas == "file":
                    sys.stdout.write("Send file called [{}] \n".format(cdict))

                    if cafter == "unescape":
                        mdat = UnEscape(mdat)

                    fwname = "configs/var_{}".format(ccalled)
                    sys.stdout.write("Send file write [{}] \n".format(fwname))

                    remote_path = "home/docker/configs/{}".format(cto)
                    helper.write(mdat, fwname)
                    runCopyTo(docker_id, fwname, remote_path)


                sys.stdout.write("Send called [{}] \n".format(cdict))
    except:
        sys.stdout.write("Send failed cdict [{}] \n".format(cdict))

    return res
# def copy_from(docker_id, local_path, remote_path):
#     log.debug("Copy file from docker {} to local file system.".format(docker_id))
#     cmd = "docker cp {}:/{} {}".format(docker_id, remote_path, local_path)
#     response = _execute_cmd(cmd)
#     return response
def runGetHelp(md,cmds):
    sys.stdout.write("get var saveas mb_client_tmp as file from client/mb_client_test_10_3.json on client\n")
    sys.stdout.write("get uri called myval from /components/pcs id myval  [on <host>] saveas myvar type float|string \n")
# mesh network
#get var called mb_client_tmp as file called client/mb_client_test_10_3.json on client
def runGet(md,cmds):
    try:
        if cmds[1] == "-help":
            runGetHelp(md,cmds)
            return []
    except:
        pass

    res = []
    cdict = myDict(cmds)
    sys.stdout.write("Get called [{}] \n".format(cdict))
    try:
        chosta = getChost(md,cdict)
        chost = chosta[0]
        #cin = chosta[1]
        #cname = chosta[2]
    except:
        sys.stdout.write(" Get unable to decode chost from {}\n".format(cdict)) 
        return []    #getChost
    
    try:
        cwhat      = cdict["get"]
        ccalled    = cdict["called"]
        #cin        = cdict["in"]
        #mdat       = md["vars"][ccalled]
        #docker_id  = chost 
        #md["hosts"][con]["system_host"]
    except:
        sys.stdout.write("Get dict failed getting vars[{}] \n".format(cdict))
        return []

    try:
        if cwhat == "var":
            try:
                cfrom        = cdict["from"]
                cas      = cdict["as"]
            except:
                sys.stdout.write("Get failed getting as[{}] \n".format(cdict))
                return []
            if cas == "json":
                fwname = "configs/var_{}.json".format(ccalled)
                #helper.write_json(mdat, fwname)
                remote_path = "home/docker/configs/{}".format(cfrom)
                runCopyFrom(chost, fwname, remote_path)
                mdx = helper.read_json(fwname)
                sys.stdout.write("get  {} read from [{}] \n".format(cwhat, fname))
                #json_string = json.dumps(mdx,indent=4)
                #sys.stdout.write(" read [{}] \n".format(json_string))
                md["vars"][ccalled] = mdx
                sys.stdout.write("Get json called [{}] \n".format(cdict))
            #get var called mb_client_tmp as file from client/mb_client_test_10_3.json on client
            elif cas == "file":
                sys.stdout.write("Get file almost available  maybe use log called [{}] \n".format(cdict))
                fwname = "configs/var_{}.file".format(ccalled)
                #helper.write_json(mdat, fwname)
                remote_path = "home/docker/configs/{}".format(cfrom)
                runCopyFrom(chost, fwname, remote_path)
                mdx = helper.read(fwname)
                sys.stdout.write("get  {} called {} read from [{}] \n".format(cwhat, ccalled, remote_path))
                #json_string = json.dumps(mdx,indent=4)
                #sys.stdout.write(" read [{}] \n".format(json_string))
                md["vars"][ccalled] = mdx
                sys.stdout.write("Get var (file)  called [{}] \n".format(cdict))
        elif cwhat == "uri":

            try:
                cid  = cdict["id"]
            except:
                sys.stdout.write(" Get unable to decode id from {}\n".format(cdict)) 
                return []    #getChost
            cas = ""
            ctype = "string"
            if "saveas" in  cdict:
                cas  = cdict["saveas"]
            if "type" in  cdict:
                ctype  = cdict["type"]

            cmd= "fims_send -m get -r/me -u {}/{} ".format(ccalled, cid)
            sys.stdout.write("Get uri cmd [{}]\n".format(cmd))
            res = runHost(chost,cmd)
            for x in  range(len(res)):
                sys.stdout.write("{}\n".format(res[x]))

            if cas != "" and len(res) > 0:
                if ctype == "string":
                    md["vars"][cas] = UnEscape(res[0])
                elif ctype == "float":
                    md["vars"][cas] = float(res[0])

    except:
        sys.stdout.write("Get failed cdict [{}] \n".format(cdict))

    return res


def runSetHelp(md,cmds):
    sys.stdout.write("set - help\n")
    #set value called connection.ip_address in mb_server_test_10_3 from config.hosts.client.system_ip_ saveas  mb_server_tmp")
    sys.stdout.write("set value called connection.ip_address in mb_client_test_10_3  from config.hosts.client.ip_address saveas  mb_client_tmp\n")
    sys.stdout.write("set uri called /components/pcs id myval from myvar [on <host>] [format single|naked|clothed] \n")


#set field called connection.ip_address in mb_client_test_10_3  from config.hosts.client.ip_address saveas  mb_client_tmp") 
# format default single
# format naked
# format clothed


def runSet(md,cmds):
    if cmds[1] == "-help":
        runSetHelp(md,cmds)
        return []

    res = []
    cdict = myDict(cmds)
    cwhat=cdict["set"]
    cformat = "single"
    if "format" in cdict:
        cformat = cdict["format"]
    if cwhat == "value":
        try:
            ccalled=cdict["called"]
            cin=cdict["in"]
            cfrom=cdict["from"]
            csave=cdict["saveas"]

            if cin not in md["vars"]:
                md["vars"][cin] = {}
            min =  md["vars"][cin]

            # create called in min
            csplit = ccalled.split(".")
            for citem in csplit[:-1]:
                if citem not in min:
                    min[citem] = {}
                min = min[citem]
            mmd = md
            # look for from in md, skip config
            csplit2 = cfrom.split(".")
            for citem in csplit2[:-1]:
                if citem == "config":
                    continue
                if citem not in mmd:
                    sys.stdout.write("Set creating citem for from  {} \n".format(citem))
                    mmd[citem] = {}
                else:
                    sys.stdout.write("Set found citem in from  {} \n".format(citem))

                mmd = mmd[citem]
            if csplit2[-1] not in mmd:
                mmd[csplit2[-1]]="dummy" 

            min[csplit[-1]] = mmd[csplit2[-1]]    
            min =  md["vars"][cin]
            #sys.stdout.write("Set {} val [{}] result[{}] \n".format(cin, csplit2[-1], min))
            min =  md["vars"][cin]
            md["vars"][csave] = copy.deepcopy(min)
            sys.stdout.write("Set {} val [{}] result[{}] \n".format(cin, csave, md["vars"][csave]))
        except:
            sys.stdout.write("Set value failed [{}]\n".format(cdict))
    elif cwhat == "uri":
        try:
            chosta = getChost(md,cdict)
            chost = chosta[0]
            #cin = chosta[1]
            #cname = chosta[2]
        except:
            sys.stdout.write(" runSet unable to decode chost from {}\n".format(cdict)) 
            return []
        try:
            ccalled=cdict["called"]
            cid=cdict["id"]
            #cin=cdict["in"]
            cfrom=cdict["from"]
            cval = getCvalue(md,cdict,"from")
            if cval != None:
                try:
                    cv = float(cval)
                    if cv < 0:
                         cval = "{}".format(cval)
                except:
                    if cval == "true" or cval == "false":
                        pass
                    else:
                        cval = "\\\"{}\\\"".format(cval)

                if cformat == "single":               
                    cmd= "fims_send -m set -u {}/{} {}".format(ccalled,cid,cval)
                elif cformat == "naked":
                    cmd= "fims_send -m set -u {} \"{{\\\"{}\\\":{}}}\"".format(ccalled,cid,cval)
                elif cformat == "clothed":
                    cmd= "fims_send -m set -u {} \"{{\\\"{}\\\":{{\\\"value\\\":{}}}}}\"".format(ccalled,cid,cval)
                sys.stdout.write("Set uri cmd [{}]\n".format(cmd))
                res = runHost(chost,cmd)
                for x in  range(len(res)):
                    sys.stdout.write("{}\n".format(res[x]))
        except:
            sys.stdout.write("Set uri failed [{}]\n".format(cdict))

    return res

# av foo 23 float
def runAv(md,cmds):
    if len(cmds) > 2:
        if len(cmds) > 3:
            if cmds[3] == "float":
                try:
                    md["vars"][cmds[1]] = float(cmds[2])
                except:
                    pass
            elif cmds[3] == "int":
                try:
                    md["vars"][cmds[1]] = int(cmds[2])
                except:
                    pass
            elif cmds[3] == "bool":
                fval = 0
                fvalok = True
                try:
                    fval = float(cmds[2])
                except:
                    fvalok = False
                    pass
                if cmds[2] == "false":
                    md["vars"][cmds[1]] = False     
                elif cmds[2] == "true":
                    md["vars"][cmds[1]] = True
                elif fvalok and float(cmds[2]) > 0:                    
                    md["vars"][cmds[1]] = True     
                elif fvalok and float(cmds[2]) <= 0:
                    md["vars"][cmds[1]] = False     
            else:
               md["vars"][cmds[1]] = cmds[2]

        else:        
            md["vars"][cmds[1]] = cmds[2]
    if cmds[1] in md["vars"]:
        return  md["vars"][cmds[1]]
    return []

#runIfRes(md,cdict,"then", res)
#runIfRes(md,cdict,"else", res)

def runIfRes(md, cdict, cthen):
    
    if "called" in cdict:
        ccalled = cdict["called"]
    else:
        ccalled = ""
    if "run" in cdict:
        crun = cdict["run"]
        if crun == "steps":
            csteps = ccalled
        elif crun == "cmd":
            ccmd = ccalled
    else:
        crun = ""

    ceq = "="
    if "+=" in cdict:
        ceq = "+="
    elif "-=" in cdict:
        ceq = "-="

    if ceq in cdict:
        cvar4 = cdict[ceq]
    try:
        cv4 = float(cvar4)
    except:
        if cvar4 in md["vars"]:
            cv4 = md["vars"][cvar4]

    if cthen in cdict:
        cvar3 = cdict[cthen]

        if cvar3 not in md["vars"]:
            md["vars"][cvar3] = ""

        if ceq == "=":
            md["vars"][cvar3] = cv4 
        elif ceq == "+=":
            md["vars"][cvar3] += cv4 
        elif ceq == "-=":
            md["vars"][cvar3] -= cv4 
    elif "run" in cdict:
        if cdict["run"] == "steps":
            try:
                cmd = "runsteps {}".format(csteps)
                runCmd(md, cmd)
            except:
                sys.stdout.write("runIfVar unable run steps {} \n".format(csteps))
            return []
    elif cdict["run"]  == "cmd":
            if ccmd[0] == "'":
                ccmd = ccmd[1:-1]
            try:
                runCmd(md, ccmd)
            except:
                sys.stdout.write("runIfVar unable run command {} \n".format(ccmd))
            return []

# if var1 > var2 then var3 = var4
# if var1 !> var2 then var3 = var4
# if var1 < var2 then var3 = var4
# if var1 !< var2 then var3 = var4
# if var1 == var2 then var3 = var4
# if var1 != var2 then var3 = var4
# if var1 != var2 run steps called steps
# if var1 != var2 run cmd called cmd
# TODO if var1 != var2 then run cmd called cmd else run cmd called nocmd
# TODO if var1 > var2 then var3 = var4 else var2 = altvar4
# find the else in cmds 
# TODO use the else feature

def runIfVar(md,cmds):
    res = []
    elseOK = False
    if "else" in cmds:
        #sys.stdout.write("runIf else found in cmds  {}  \n".format(cmds))
        ix = 0 
        elseOK = True
        elseix = -1
        while ix < len(cmds):
            #sys.stdout.write("ix {} cmd  {}  \n".format(ix,cmds[ix]))
            if cmds[ix] == "else":
                elseix = ix
                break
            ix += 1
        if elseix != -1:
            cdict = myDict(cmds[:elseix])
            cdicte = myDict(cmds[elseix:])
            #sys.stdout.write("runIf else found cdict  {} cdicte {} \n".format(cdict,cdicte))
    else:
        cdict = myDict(cmds)
        cdicte = {}
    cvar1 = cdict["if"]
    cvar2 = ""
    cvar3 = ""
    cvar4 = ""

 
    cact = ""
    if ">" in cdict:
        cact = ">"
    elif "!>" in cdict:
        cact = "!>"
    if "<" in cdict:
        cact = "<"
    if "!<" in cdict:
        cact = "!<"
    if "==" in cdict:
        cact = "=="
    if "!=" in cdict:
        cact = "!="

    if cact in cdict:
        cvar2 = cdict[cact]
 
   
    cv2 = 0

    if cvar1 not in md["vars"]:
        sys.stdout.write("runIf error {} not in vars   \n".format(cvar1))
        return []

    try:
        cv2 = float(cvar2)
    except:
        if cvar2 not in md["vars"]:
            sys.stdout.write("runIf error {} not in vars   \n".format(cvar2))
            return []
        else:
            cv2 = md["vars"][cvar2]
 
    if cvar1 not in md["vars"]:
        md["vars"][cvar1] = ""
    # if cvar2 not in md["vars"]:
    #     md["vars"][cvar2] = ""
    sys.stdout.write("runIfVar try  {} {} {} \n".format(md["vars"][cvar1], cact, md["vars"][cvar2]))

    try:    
        # if cact == ">":
        #     if md["vars"][cvar1] > md["vars"][cvar2]:
        #         md["vars"][cvar3] = md["vars"][cvar4]
        resok = False
        if cact == "!>":
            if md["vars"][cvar1] <= cv2:
                resok = True

        # elif cact == "<":
        #     if md["vars"][cvar1] < md["vars"][cvar2]:
        #         md["vars"][cvar3] = md["vars"][cvar4]
        elif cact == "!<":
            if md["vars"][cvar1] >= cv2:
                resok = True

        elif cact == "==":
            if md["vars"][cvar1] == cv2:
                resok = True
        elif cact == "!=":
            if md["vars"][cvar1] != cv2:
                resok = True
        #cres = md["vars"][cvar3] 
    except:
        sys.stdout.write("runIfVar did not compute  cdict [{}] \n".format(cdict))


    if cact == ">":
        sys.stdout.write("runIfVar compute {} > {} \n".format(md["vars"][cvar1],md["vars"][cvar2]))

        if md["vars"][cvar1] > cv2:
            resok = True
        #md["vars"][cvar3] 
    elif cact == "<":
        sys.stdout.write("runIfVar compute {} < {} \n".format(md["vars"][cvar1],md["vars"][cvar2]))
        if md["vars"][cvar1] < cv2:
            resok = True
    try:
        if resok == True:
            try:
                runIfRes(md, cdict, "then")
            except:
                sys.stdout.write("runIfRes  then failed cdict {}\n".format(cdict))

        elif elseOK == True:
            runIfRes(md, cdicte, "else")
                # cvar3 = cdicte["else"]
                # if cvar3 in md["vars"]:
                #     md["vars"][cvar3] = ""
                # ceq = ""
                # if "=" in cdicte:
                #     ceq = "="
                # elif "+=" in cdicte:
                #     ceq = "+="
                # elif "-=" in cdicte:
                #     ceq = "-="
                # cvar4 = cdicte[ceq]
                # cv4 = 0
                # try:
                #     cv4 = float(cvar4)
                # except:
                #     if cvar4 in md["vars"]:
                #         cv4 = md["vars"][cvar4]
                #     else:
                #         sys.stdout.write("runIfVar unable to execute else {} on  {}  with {} var4 missing\n".format(ceq, cvar3,res))
                #         return []
                # try:
                #     if ceq == "=":
                #         md["vars"][cvar3] = cv4
                #     elif ceq == "+=":
                #         md["vars"][cvar3] += cv4 
                #     elif ceq == "-=":
                #         md["vars"][cvar3] -= cv4
                # except:
                #         sys.stdout.write("runIfVar unable to execute else {} on  {}  with {} \n".format(ceq, cvar3,cv4))
                #         return []
 

    except:
        sys.stdout.write("runIfVar unable to execute cdict {} cdicte {} \n".format(cdict,cdicte))
        return []
    #cres = md["vars"][cvar3]
    return []

#find 'Inserted map entry' from clilog into clifind before 2 after 1
#find pub from fims_listen_01 saveas fims_listen_02_pub after 1
def runFind(md,cmds):
    res = []
    try:
        cdict = myDict(cmds)
    except:
        print(" runFind  cdict error")
        return res

    cinto = ""
    cbefore = ""
    cafter = ""
    countvar = ""
    before = 0
    after = 0

    if "countinto" in cdict:
        countvar = cdict["countinto"]
    if "into" in cdict:
        cinto = cdict["into"]
    elif "in" in cdict:
        cinto = cdict["in"]
    elif "saveas" in cdict:
        cinto = cdict["saveas"]

    if "before" in cdict:
        cbefore = cdict["before"]
        before = float(cbefore)
        #sys.stdout.write(" before {:02f}\n".format(before))
    if "after" in cdict:
        cafter = cdict["after"]
        after = float(cafter)
        #sys.stdout.write(" after {:02f}\n".format(after))

    try:
        cfind = cdict["find"]
        if cfind[0] == "'":
            cfind = cfind[1:-1]
        cfrom = cdict["from"]
        xres = md["vars"][cfrom]

        sys.stdout.write(" seeking [{}] in [{}]\n".format(cfind, cfrom))
        count = 0
        for x in  range(len(xres)):
            if xres[x].find(cfind) >=0:
                count += 1
                six = x
                eix = x
                if before > 0 or after > 0:
                    six = x - before
                    eix = x + after
                    if six < 0:
                        six = 0
                    if eix >= len(xres):
                        eix = len(xres) -1

                #sys.stdout.write(" appending from  {} to {}\n".format(six,eix))
                while six <= eix:
                    res.append(xres[int(six)])
                    six+=1
                sys.stdout.write(" found  {}\n".format(xres[x]))
        if len(cinto) > 0:
            md["vars"][cinto] = res
        if len(countvar) > 0:
            md["vars"][countvar] = count


    except:
        sys.stdout.write(" runFind not understood cdict [{}]".format(cdict))
    return []


def init_menu(test_list):
    Scen.setupMd(md)
    #print (" setting up test menu\n")
    # docker_host = ""
    # system_id = "DNP3_test"
    # servcfg = "/home/docker/configs/mb_server_test_10_3.json"
    # clicfg = "/home/docker/configs/mb_client_test_10_3.json"
    # servsh = "/home/docker/configs/mb_server_test_10_3.sh"
    md["system_host"] = docker.get_docker_id(md["system_id"])
 
    # for file in os.listdir(menu_dir):
    #     if fnmatch.fnmatch(file, menu_file):
    #         menu_list.append(os.path.join(menu_dir, file))
    #         menu_cfg = cfg.read_test_cfg(menu_dir+"/"+file)

    # #print (test_list)
    # print("Menu Items")
    # #print(menu_cfg)
    # for each in menu_cfg["items"]:
    #     #print(each)
    #     print("Id {} name {}".format(each["id"], each["name"]))
    #     #print()
    # for testb in menu_cfg["testbeds"]:
    #     for controller in testb["controllers"]:
    #         print("Id {} name {}".format(controller["id"], controller["name"]))
    #         controller["docker"] = docker.get_docker_id(controller["name"])

    # print()
    # print("Tests")
    # for each in test_list:
    #     print("Id {} name {}".format(each["id"], each["name"]))
    #     #print()
    
    quit = 0
    sys.stdout.write(" Interactive Gherkin Pickler \n")

    runCmd(md,"runsteps init")
    # runCmd(md,"setHost DNP3_test test")
    # runCmd(md,"setHost DNP3_client client")
    showMenu(md)

    while quit == 0:
        sys.stdout.write(" Enter a command (help is good) :")
        sys.stdout.flush()
        line = sys.stdin.readline()
        #dline=bytes(line,"utf-8").decode("unicode_escape")
        #dline=bytes(line,"utf-8")
        # here are some test commands until we workout how to do this.
        #
        if len(line) > 1 :
            #md["steps"][md["stepset"]]["cmds"].append(line[:-1])
            #cmds=mySplit(line)
            #print(cmds)
            sset = md["stepset"]
            quit = runCmd(md,line)
            if quit < 0:
                md["steps"][sset]["cmds"].append(line[:-1])
                quit = 0

def mySplit(line):
    res = []
    str=""
    esc = False
    for i in line:
        if i == " " and esc == False:
            if len(str) > 0:
                res.append(str)
                str = ""
            continue
        elif i == "\n":
            continue
        elif i == "'" and esc == False:
            esc = True
            str+=i

        elif i == "'" and esc == True:
            str+=i
            res.append(str)
            str = ""
            esc = False
        else:
            str+=i

    if len(str) > 0:
        res.append(str)

    return res

def myDict(res):
    myd = {}
    a1 =""
    b1 = ""
    for ix in range(len(res)):
        #print ("[{}] => [{}]".format(ix,res[ix]))
#        if ix == 0:
#            continue
        b1 = a1
        a1 = res[ix]
        if (ix-1) % 2 == 0:
            myd[b1] = a1


    return myd

def runCmd(md, line):
    quit = -1
    cmds = mySplit(line)
    cmd_dict = myDict(cmds)
    #print(cmd_dict)

    if len(cmds) > 1 :
        if cmds[0] == "setHost":
            xmd = md
            # setHost DNP3_test as client
            if len(cmds) > 2:
                xas = cmds[2]
                if xas == "as":
                    xas = cmds[3]                
                try :
                    xmd = md["hosts"][xas]
                except KeyError:
                    md["hosts"][xas]={}
                    xmd = md["hosts"][xas]

            try:
                xmd["system_host"] = docker.get_docker_id(cmds[1])
                xmd["system_id"] = cmds[1]
                xmd["system_host"] = docker.get_docker_id(cmds[1])
                xmd["system_ip"] = docker.get_docker_ip(xmd["system_host"])
                xmd["system_path"]="docker"
                xmd["system_name"]=xas
                #sys.stdout.write(" host for :[{}] is : [{}] \n".format(xmd["system_id"],xmd["system_host"]))
                md["system_id"] = xmd["system_id"]
                md["system_host"] = xmd["system_host"]
                md["system_ip"] = xmd["system_ip"]
                md["system_path"] = xmd["system_path"]
                md["system_name"] = xmd["system_name"]
            except:
                sys.stdout.write(" Not a docker system [{}] \n".format(cmds[1]))

         #setip  clicfg from client")

        #scen["given"]["steps"].append("run modbus_server with mbservcfg in client")
        elif cmds[0] == "run":
            runRun(md,cmds)
        elif cmds[0] == "save":
            runSave(md,cmds)
        elif cmds[0] == "load":
            runLoad(md,cmds)
        elif cmds[0] == "show":
            runShow(md,cmds)
        elif cmds[0] == "set":
            runSet(md,cmds)
        elif cmds[0] == "send":
            runSend(md,cmds)
        elif cmds[0] == "get":
            runGet(md,cmds)

        # wait 5 (seconds)
        elif cmds[0] == "wait":
            runWait(md,cmds)

        elif cmds[0] == "stop":
            runStop(md,cmds)

        #log modbus_server with mbservcfg into clilog
        elif cmds[0] == "log":
            runLog(md,cmds)
        #find 'Inserted map entry' from clilog clifind
        elif cmds[0] == "find":
            runFind(md,cmds)

        elif cmds[0] == "if":
            runIfVar(md,cmds)

        elif cmds[0] == "setip":
            runSetip(md,cmds)

        elif cmds[0] == "runsteps":
            print ("runsteps multi")
            runSteps(md,cmds)            

        elif cmds[0] == "usesteps":
            useSteps(md,cmds[1])            

        elif cmds[0] == "addVar" or cmds[0]== "av":
            runAv(md,cmds)

        elif cmds[0] == "use":
            #runSetip(md,cmds)
            runUse(md,cmds)
        elif cmds[0] == "add":
            #runSetip(md,cmds)
            runAdd(md,cmds)
        elif cmds[0] == "seek":
            #runSetip(md,cmds)
            runAdd(md,cmds)


        elif cmds[0] == "setVar" or cmds[0]== "sv":
            if len(cmds) > 2:
               comp=md["vars"][cmds[1]]
               cmd = "fims_send -m set -r /{} -u {} {}".format(os.getpid(), comp, cmds[2])
               print(cmd)
               runHost(md["system_host"], cmd)

        elif cmds[0] == "pubVar" or cmds[0]== "pv":
            if len(cmds) > 2:
               comp=md["vars"][cmds[1]]
               cmd = "fims_send -m pub  -u {} {}".format(comp, cmds[2])
               print(cmd)
               runHost(md["system_host"], cmd)

        elif cmds[0] == "getVar" or cmds[0]== "gv":
            if len(cmds) > 1:
               comp=md["vars"][cmds[1]]
               cmd = "fims_send -m get -r /{} -u {}".format(os.getpid(),comp)
               print(cmd)
               runHost(md["system_host"], cmd)

        elif cmds[0] == "logfims":
            ltime="5"
            if len(cmds) > 1:
                ltime = cmds[1]
            sys.stdout.write(" ltime [{}] \n".format(ltime))

            runHost(md["system_host"],"{}/runlog.sh {} fims_listen {}{}".format(md["scripts"],ltime, md["logdir"], md["fimslog"]))

        elif cmds[0] == "pkill":
            pkill="fims_server"
            if len(cmds) > 1:
                pkill = cmds[1]
            execRes(md["system_host"],"pkill {}".format(pkill))

        elif cmds[0] == "getlog":
            plog=md["fimslog"]
            if len(cmds) > 1:
                plog = cmds[1]
                if plog == "fims":
                    plog=md["fimslog"]
                elif plog == "client":
                    plog=md["clilog"]
                elif plog == "server":
                    plog=md["srvlog"]

            xxcmd="cat {}{}".format(md["logdir"],plog)
            execRes(md["system_host"],xxcmd)

        elif cmds[0] == "sstep":
            if len(cmds) > 1:
                var = cmds[2]
                if var[0] == "'":
                    var =  cmds[2][1:-1]
                md["steps"][md["stepset"]][cmds[1]] = var


    else:
        line = line[:-1]
        print (line)
        # quit
        if line == "todo":
            sys.stdout.write("\tsets send varlist via fim_send\n")
            sys.stdout.write("\tgets via fim_send\n")
            sys.stdout.write("\tsend fixup object navigator\n")
            sys.stdout.write("\tcmd:: use scenario called setup_system id given name 'Set up the Client' step 'set up configs'\n") 
            sys.stdout.write("\tfix as file / as json\n")
            sys.stdout.write("\tuse and add\n")
            sys.stdout.write("\tadd scenario called setup_system id given name 'Set up the Client' step 'kill processes'\n") 
            sys.stdout.write("\tafter use , edit actions\n")
            sys.stdout.write("\ton / in client\n")
            
            sys.stdout.write("DONE \tfims_send -m set but add send var list\n")
            sys.stdout.write("\ttidy up dm scens\n")
            sys.stdout.write("\tfims_listen\n")
            sys.stdout.write("DONE \tVar Lists; Use Vars from varlist\n") 
            sys.stdout.write("DONE\tlog file processing\n")
            sys.stdout.write("DONE\tuse con selected host for runRun\n")

        elif line == "q" or line == "quit":
            sys.stdout.write(" OK quitting\n")
            quit = 1
        ## ps
        elif line == "ps" and md["system_host"] != "":
            execRes(md["system_host"],"ps -ax")
        ## top
        elif line == "top" and md["system_host"] != "":
            execRes(md["system_host"],"top -b -n 1")
        ## logs
        elif line == "logs" and md["system_host"] != "":
            execRes(md["system_host"],"top -b -n 1")
            sys.stdout.write( "modbus_server ---------------------------------------\n")
            cmd = "cat {}{}".format(md["logdir"],md["srvlog"])
            execRes(md["system_host"], cmd)
            sys.stdout.write( "modbus_client ---------------------------------------\n")
            cmd = "cat {}{}".format(md["logdir"],md["clilog"])
            execRes(md["system_host"], cmd)

            # res = runHost(system_host, "ps -ax")
            # for x in  range(len(res)):
            #     sys.stdout.write("{}\n".format(res[x]))
        ## help
        elif line == "h" or  line == "help":
            showMenu(md)
        ## show config
        elif cmds[0] == "showcfg":
            json_string = json.dumps(md,indent=4)
            sys.stdout.write(" config [{}] \n".format(json_string))

        elif cmds[0] == "showscn":
            json_string = json.dumps(md["scenarios"],indent=4)
            sys.stdout.write(" scenarios [{}] \n".format(json_string))

        elif cmds[0] == "showvars":
            json_string = json.dumps(md["vars"],indent=4)
            sys.stdout.write(" vars [{}] \n".format(json_string))

        elif cmds[0] == "showsteps":
            json_string = json.dumps(md["steps"],indent=4)
            sys.stdout.write(" steps [{}] \n".format(json_string))

        elif cmds[0] == "runfims":
            runHost(md["system_host"],"{}/runlog.sh 0 fims_server {}/fims.log".format(md["scripts"],md["logdir"]))

        elif cmds[0] == "logfims":
            ltime="5"
            if len(cmds) > 1:
                ltime = cmds[1]
            sys.stdout.write(" ltime [{}] \n".format(ltime))

            runHost(md["system_host"],"{}/runlog.sh {} fims_listen {}/fims_listen.log".format(md["scripts"],ltime, md["logdir"]))

        elif cmds[0] == "pkill":
            pkill="fims_server"
            if len(cmds) > 1:
                pkill = cmds[1]
            execRes(md["system_host"],"pkill {}".format(pkill))

        elif cmds[0] == "getlog":
            plog="fims_listen.log"
            if len(cmds) > 1:
                plog = cmds[1]
            xxcmd="cat {}/{}&".format(md["logdir"],plog)
            execRes(md["system_host"],xxcmd)

        elif cmds[0] == "runSteps":
            print ("runsteps single")
            runSteps(md,cmds)

    return quit


    # setHost set the working host
    # ps show proceses
    #     
    #ssh.remote_command("echo foo",["","","localhost",""])


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
