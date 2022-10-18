
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
     "ess_controller|storage.json|replace|system.client.dbName|lab"
     "ess_controller|stuff.json|template|cfgEsslabStuff"
)

