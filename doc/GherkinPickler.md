Gherkin Pickler 

P Wilshire
01.23.2023


### Objective

To provide a system to create and run Gherkin style test patterns on a multi host system.

The multi host system can be multiple docker containers , external hardware or vm systems. 
It is envisioned that a combination of all of these options can be used together to perform a given series of tests.

Use of the Gherkin framework permits this system to be integrated into higher level testing frameworks.

### Major components

The major components of this system are :

* Hosts

These are systems running on some sort of physical or virtual environemnt.
Initially the system will just use "docker" containers but this will be extended to use http, ssh  and other connections.
The system creates a common definition of a host and sends messages to and gets mesage from any given host to run the tests.

Each host is given a name and a type to indicate the connection method.
Example hosts
```
show  hosts [{
    "client": {
        "system_id": "DNP3_client",
        "system_host": "6a2426b3cb94",
        "ip_address": "",
        "path": "docker",
        "system_ip": "172.17.0.4",
        "system_path": "docker",
        "system_name": "client"
    },
    "server": {
        "system_id": "DNP3_server",
        "system_host": "c33f248e6b88",
        "ip_address": "",
        "path": "docker",
        "system_ip": "172.17.0.2",
        "system_path": "docker",
        "system_name": "server"
    },
    "test": {
        "system_host": "c527a328bf1d",
        "system_id": "DNP3_test",
        "system_ip": "",
        "system_path": "docker",
        "system_name": "test"
    }
}]

```

* Steps

Steps are lists of commands to be issued to perform a test operation.
These may be instructions to start or stop a program or instructions to send (fims) messages to the programs running on the hosts.
Additional commands are used to extract log data or component data from the systems.

Steps are grouped by name and when a sequence of steps are run on the system the results are collected and retained.

A named set of steps are attached to Gherkin operations to create a test sequence.

Example steps
```

show steps [{

    "test0": {
        "cmds": [
            "stop modbus_client on client",
            "stop fims_server on client",
            "stop modbus_server on server",
            "stop fims_server on server",
            "stop fims_echo on server"
        ]
    },
    "test1": {
        "cmds": [
            "load var called mb_server_test_10_3 from mb_server_test.json as json",
            "load var called mb_server_test_10_3_echo from mb_server_test_10_3.sh as file",
            "load var called mb_client_test_10_3 from mb_client_test.json as json",
            "set value called connection.ip_address in mb_client_test_10_3 from config.hosts.server.system_ip saveas  mb_client_tmp",
            "set value called system.ip_address in mb_server_test_10_3 from config.hosts.server.system_ip saveas  mb_server_tmp",
            "send var called mb_client_tmp as json to client/mb_client_test_10_3.json on client",
            "send var called mb_server_tmp as json to server/mb_server_test_10_3.json on server",
            "send var called mb_server_test_10_3_echo after unescape as file to server/mb_server_test_10_3_echo.sh on server"
        ]
    },
    "test2": {
        "cmds": [
            "run fims_server on client",
            "run fims_server on server",
            "run server/mb_server_test_10_3_echo.sh on server type script logs echo",
            "run modbus_server with server/mb_server_test_10_3.json on server",
            "run modbus_client with client/mb_client_test_10_3.json on client"
        ]
    },
    "test3": {
        "cmds": [
            "run fims_listen for 5 logs listen_01 on client",
            "wait 5 seconds",
            "log listen_01 from listen_01 on client saveas fims_listen_01",
            "find pub from fims_listen_01 saveas fims_listen_02_pub after 1",
            "find comp2 from fims_listen_02_pub saveas fims_listen_temp countinto comp2_count",
            "find comp1 from fims_listen_02_pub saveas fims_listen_temp countinto comp1_count"
        ]
    }
```


* Vars

The system uses a collection of variables saved in named lists
when running the default var list can be changed to suit the needs of the application.
The named var lists each contain named vars which can contain numerics,boolean, string, array and dictionary objects.   
A "use" command can change the current "named" list of vars as required.
Note the system will have a push and pop operation on the var lists in use. This will allow the working set of vars to be replaced but retained in memory for retrieval when needed.

Example vars
```
show  vars [{
    "base":{
        "v1": "/components/comp2/24_decode_id",
        "v2": "/components/comp1/01",
        "v3": "/components/comp1/02"
        },
    "test1": {
        "result value":234,
        "test value":-45
    }
}]

```

* Scenarios

These are Gherkin Scenarios.
They are collections of operations to be performed to conduct a test sequence.

The system creates a "Gherkin like" structure to control these sequences.

# Basic Gherkin

Gherkin (as far as I know) utilizes a series of named test "scenarios".
Each scenario has a number of what I'll call phases.
Each phase can have one or more named "operations".
An Operation will have a number of named steps which in turn will have a list of commands.

Example scenarios

```
show scn
 scenarios [{
    "setup_system": {
        "given": [{
                "Set up the Client": {"steps": [{
                            "kill processes": { "name": "kill processes",
                                                 "cmds": ["stop modbus_client on client",
                                                          "stop modbus_server on server",
                                                          "stop fims_server on client",
                                                          "stop fims_server on server",
                                                          "stop fims_echo on server"],
                                                 "results": {}
                                               }},{
                            "set up configs": { "name": "set up configs",
                                                "cmds": [
                                    "load var called mb_server_test_10_3 from mb_server_test as json",
                                    "load var called mb_server_test_10_3_echo from mb_server_test_echo.sh as file",
                                    "load var called mb_client_test_10_3 from mb_client_test as json",
                                    "set value called connection.ip_address in mb_client_test_10_3 from config.hosts.server.system_ip saveas  mb_client_tmp",
                                    "set value called connection.ip_address in mb_server_test_10_3 from config.hosts.server.system_ip_ saveas  mb_server_tmp",
                                    "send var called mb_client_tmp as json to client/mb_client_test_10_3.json in client",
                                    "send var called mb_server_tmp as json to server/mb_server_test_10_3.json in server",
                                    "send var called mb_server_test_10_3_echo as file to server/mb_server_test_10_3_echo.sh in server"
                                                ],
                                                "results": {}
                            }},{
                            "run system": { "name": "run system",
                                            "cmds": [
                                    "run fims_server on client",
                                    "run fims_server on server",
                                    "run fims_echo with server/mb_server_test_10_3.sh on server",
                                    "run modbus_server with server/mb_server_test_10_3 on server",
                                    "run modbus_client with client/mb_client_test_10_3 on client"
                                                    ],
                                            "results": {}
                            }}
                    ]} }] }
}]

```

### Scenario Phases

## Given
This is a phase where the system is set up to preppare for the test.
Each test is set up in from a "clean" or well known start point.
The "given" phase will have to ensure that the test system is reset to a base or idle state , the components to be tested are then introduced to the target systems, with correct configurations and environment settings  in a controlled manner.

The Gherkin "given" phase may have additional meanings and requirements so this understanding may well need to be modified.

## When
This is a phase where the "to be tested" elements are  introduced into the system.
The test sequences are initialted

## Then 
This is the phase where data is collected from the test system and the results compared against expected outcomes.


### Interactive commands

The process can in load its configuration(s)  from one or more config (json) files.
The process can then run in batch mode where one or more scenarios are executed.
The results from these operations can be saved to one (or more ) results files.

This process can also run inteactively to build and test batches of commands and develop the command sets for use in the scenario test phases.

Here is an example of the help screen.

```
 -------------------------------------------------------------------------------
 FlexGen Gherkin Pickler  host  [client] id [6a2426b3cb94] docker [DNP3_client]
 -------------------------------------------------------------------------------
 (h)elp                    :- show menu
 basic commands ------------------(cmd) -help  for more info -------------------
 run                       :- run something on a host with args and / or configs
 stop                      :- stop something on a host based on name or pid
 log                       :- get a log file
 use (sname) called (name) :- switch target host
 ps                        :- show processes on a host
 top                       :- show processes on a host
 add                       :- add a scenario, step or a var
 get                       :- get something from a host  file json uri
 set                       :- set something on a host  file json uri
 show xx [called yy]       :- config|scenarios|steps|hosts|vars
 other commands -----------------------------------------------------------------
 runsteps name              :- run a series of commands from a list of steps
 av <vname> <value> <type>  :- set a variable <name> to a value as a type
 find <string> from <vname>  saveas <rvname> countinto <countvar
 wait <time in secs> seconds
 if var1 > var2 then var3 = var4 else var2 = altvar4
 load xx [called yy] from fname   :- config|scenarios|steps from file
 send xx [called yy] from fname   :- config|scenarios|steps from file
 save xx [called yy] in fname     :- config|scenarios|steps into file
 setHost (name)                   :- set docker host info ( container must be running)
 pkill (name)                     :- kill processes on host
 (q)uit                           :- exit

 Enter a command (help is good) :
 ```

In addition each command has (or will have) a -help option showing examples of the use of that command.

```
 Enter a command (help is good) :run -help
        run - help
        run  a designated task on the selected host
        run fims_server ( uses default host)
        run fims_server on <client>   -- designate the host to use
        run fims_server on <client> for 5   -- use a 5 second timeout
        run fims_server with <config_file> on <client>
        run fims_server logs <log_file> on <client>
        run fims_server args 'special args' on <client>
        run something_else type <exec|script> on <client> -- run an executable or a script
        run steps called 'some name' mode ask|debug
        run scenario called myscenario
        run phase called given in myscenario
        run op called 'this is the first op'  in myscenario phase given
        run steps called 'some name' op 'this is the first op'  in myscenario phase given  mode run
```

Some commands work on a "selected" host or target system.


Here is an example of an interactive command session.

```
Enter a command (help is good) : use server
Use [server] called  [server]

Enter a command (help is good) : ps
running ps -ax
PID TTY      STAT   TIME COMMAND
    1 pts/0    Ss+    0:00 /bin/bash
   69 ?        Rs     0:00 ps -ax

Enter a command (help is good) : run fims_listen
runRun fcn =[fims_listen] cfg = [] dir = [server] cname [server] ctype [exec]

Enter a command (help is good) : run fims_listen

Enter a command (help is good) :log fims_listen
fcn =[fims_listen] cfg = [fims_listen] dir = [server]
cmd = [cat /home/docker/configs/server/logs/fims_listen.log]


fims_listen: Failed to make connection to FIMS.
Connect failed.
 runLog completed OK

```

### Test Results
The output from any command can be saved into a variable and then used for analysis to calculate test results.

Here, for example, are some rules that extract data from a log file.

```
 "test3": {
        "cmds": [
            "run fims_listen for 5 logs listen_01 on client",
            "wait 5 seconds",
            "log listen_01 from listen_01 on client saveas fims_listen_01",
            "find pub from fims_listen_01 saveas fims_listen_02_pub after 1",
            "find comp2 from fims_listen_02_pub saveas fims_listen_temp countinto comp2_count",
            "find comp1 from fims_listen_02_pub saveas fims_listen_temp countinto comp1_count"
        ]
    }
```
The variables comp2_count and comp1_count  contain the number of pubs detected in a 5 second period from high speed and low speed output from the modbus_client on the client node.

The system can then extract the count values and direct those back in to the scenario result.

```
set config called 'scenarios.myscenario.then.\'test fast pubs\'.result' value Fail
set config called 'scenarios.myscenario.then.\'test slow pubs\'.result' value Fail
if comp2_count > 95 then run 'set config called scenarios.myscenario.then.\'test fast pubs\'.result value Pass'
if comp1_count > 9 then run 'set config called scenarios.myscenario.then.\'test slow pubs\'.result value Pass'

```

### Save/Load

The save/load commands allow the user to save and load variables from files in the config directory.
Variables can be saved and loaded  as text object as an array of strings.
Variables can also be saved/loaded  as json objects.

Log files from operations on target hosts are saved as text arrays. 
They can be saved in system variables and the "find" command used to extract data from these files or variables.
The find command can work much like a simple version of the "grep" utility.

Data extracted from a "find" operation can be saved into another variable.

When the "json" save/load option is used the data targets can be config files.
Data, like ip_addresses or port numbers, can be modified after loading to allow the changed files to be transferred to target hosts.

Here are some examples of load commands coupled with some data manipulation options.

The default load directory is the configs directory specified at startup. This defaults to the local "configs" directory. 

```
"load var called mb_server_test_10_3 from mb_server_test as json",
"load var called mb_server_test_10_3_echo from mb_server_test_echo.sh as file",
"load var called mb_client_test_10_3 from mb_client_test as json",
"set value called connection.ip_address in mb_client_test_10_3 from config.hosts.server.system_ip saveas  mb_client_tmp",
"set value called connection.ip_address in mb_server_test_10_3 from config.hosts.server.system_ip_ saveas  mb_server_tmp",
"send var called mb_client_tmp as json to client/mb_client_test_10_3.json in client",
"send var called mb_server_tmp as json to server/mb_server_test_10_3.json in server",
"send var called mb_server_test_10_3_echo as file to server/mb_server_test_10_3_echo.sh in server"
```









