
p.wilshire
10_18_2022


The fixFile option presents some interesting posibilites

* A config file may be processed by means of a template
* A config file may be processed by means of a template_expansion (multiple racks)
* A config file may be simple subjecte to a name/value alteration using a object with a defined path.



cfgEsslabStuff=(
    "##dbName##|labdb"
    "##Dir##|/home/docker/lab_db"
)    


cfgFiles=(    
     "config/ess_controller/storage.json|replace|system.client.dbName|lab"
     "config/ess_controller/dts.json|replace|dbName|mylab"
     "ess_controller|stuff.json|template|cfgEsslabStuff"
)


fixFile.go code allows the following replacement to work.
This gives us navigation into  json file and a value replacement function.

fixFile [-dir ./] -file cs.json  [-output cs_out.json] -val "/home/hybridos/db/cloud_sync"  -path "servers.local.directory"


Then  fixFiles can run like this

fixFiles [-dir ./] -template file.tmpl  [-output cs_out.json] -flist flist.txt 


Pull in a file list and a template list 
for each file 
replace all template expressions with replacements
replace all files follwing instructions in the flist



