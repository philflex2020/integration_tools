package main

// p wilshire
// 10_17_2022
//   10_19_2022 made it recursive  system.target.ip
// replace a named field in a json file
// used in the integration_tools utility

import (
	"fmt"
	"os/exec"

	//"log"
	//"unsafe"
	"flag"
	"io/ioutil"
	"os"
	"strings"
)

// func ReplaceBytes(data []byte, ix int, iy int, rep []byte) (value []byte, err error) {
// 	return append(data[:ix], append(rep, data[iy:]...)...), nil
// }

func addTemplate(fname string, tm *map[string]string) {

	cfile := fmt.Sprintf("%s/%s", ".", fname)
	input, err := ioutil.ReadFile(cfile)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	keya := strings.Split(string(input), "\n")
	for ki, k := range keya {
		l := len(k)
		if l > 2 {
			//k := k[1 : l-1]
			ka := strings.Split(string(k), "|")
			fmt.Printf(" idx  [%d] line [%v]  rep [%v] with [%s]\n", ki, k, ka[0], ka[1])
			(*tm)[ka[0]] = ka[1]
		}
	}

}

func repFile(fname, key, val string, tm *map[string]string) (err error) {

	cfile := fmt.Sprintf("%s/%s", ".", fname)
	input, err := ioutil.ReadFile(cfile)
	if err != nil {
		fmt.Println(err)
		return err
		//os.Exit(1)
	}
	keya := strings.Split(string(input), "\n")
	//config/ess_controller/storage.json|replace|system.client.dbName|lab
	for _, k := range keya {
		l := len(k)
		if l > 2 {
			//k := k[1 : l-1]
			ka := strings.Split(string(k), "|")
			cmdst := fmt.Sprintf(" ./fixFile  -file %s  -output %s  -path %s\n", ka[0], ka[2], ka[3])
			cmd := exec.Command(cmdst)
			err := cmd.Run()
			if err != nil {
				fmt.Printf("error [%v]\n", err)
			}
		}
	}
	return err
}

func main() {

	tMap := make(map[string]string)
	fmt.Printf(" tMap type %T\n", tMap)
	cfgFile := flag.String("flist", "flist.txt", "file list")
	//cfgOutFile := flag.String("output", "dummy.json", " output file to use")
	cfgDir := flag.String("dir", "./", " optional dir ")
	//cfgKey := flag.String("key", "ip_address", " key to find")
	//cfgVal := flag.String("val", "127.0.0.1", " new value")
	//cfgPath := flag.String("path", "servers.local.ip", "path to object")

	flag.Parse()

	cfile := fmt.Sprintf("%s/%s", *cfgDir, *cfgFile)
	//cout := fmt.Sprintf("%s/%s", *cfgDir, *cfgOutFile)

	input, err := ioutil.ReadFile(cfile)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	fmt.Printf(" data ## ##[%s]\n", string(input))
	keya := strings.Split(string(input), "\n")
	for ki, k := range keya {
		l := len(k)
		if l > 2 {
			//k := k[1 : l-1]
			ka := strings.Split(string(k), "|")
			fmt.Printf(" idx  [%d] line [%v]  file [%v] action [%s]\n", ki, k, ka[0], ka[1])
			if ka[1] == "template" {
				addTemplate(ka[0], &tMap)
			} else if ka[1] == "replace" {
				//func repFile(fname, key, val string, tm *map[string]string) {
				repFile(ka[0], ka[2], ka[3], &tMap)
			}
			//func ipFile(mapname, flist, tm *map[string]string) {

		}
	}
}

// 	dt := 0
// 	s := 0
// 	e := 0
// 	q := 0
// 	//st := 0
// 	//n := 0
// 	dt, s, e, q, err = FindPath(input, *cfgPath) // string("servers.local"))
// 	if err == nil {

// 		fmt.Printf(" path [%v] %T found, data type %v s %v e %v q %v val [%s]\n", *cfgPath, *cfgPath, dt, s, e, q, string(input[s:e]))
// 	} else {
// 		fmt.Printf(" path [%v] %T Not Found err [%v] \n", *cfgPath, *cfgPath, err)

// 	}

// 	//os.Exit(1)
// 	{
// 		newval := []byte(*cfgVal)
// 		if dt == 1 {
// 			newval = []byte(strconv.Quote(string(newval)))
// 		}
// 		newtemp, _ := ReplaceBytes(input, s, e, newval)
// 		if err = ioutil.WriteFile(cout, newtemp, 0666); err != nil {
// 			fmt.Println(err)
// 			os.Exit(1)
// 		}
// 	}
// }
