package main

// p wilshire
// 10_17_2022
//   10_19_2022 made it recursive  system.target.ip
// replace a named field in a json file
// used in the integration_tools utility

import (
	"fmt"
	"strconv"

	//"log"
	//"unsafe"
	"flag"
	"io/ioutil"
	"os"
	"strings"
)

// Data types available in valid JSON data.
const (
	NotExist = iota
	String
	Number
	Object
	Array
	Boolean
	Null
)

func ReplaceBytes(data []byte, ix int, iy int, rep []byte) (value []byte, err error) {
	return append(data[:ix], append(rep, data[iy:]...)...), nil
}

// look for "<string>": pattern to find a name
func GetName(data []byte, sid, ln int) (sidx, eidx, nidx, pidx int) {
	if sid < 0 {
		return -1, 0, 0, 0
	}
	idx := sid
	qidx := 0
	state := 0
	for state != -1 {
		switch state {
		case 0: // looking for start quote
			if data[idx] == byte('"') {
				state = 1
				sidx = idx
			}

		case 1: // check data after quote
			c := data[idx]
			// stop on any of these
			if c == ' ' || c == '\n' || c == ',' || c == '}' || c == ']' || c == '{' || c == '[' || c == 9 || c == ':' {
				state = 0
			}
			// this is the endquote
			if c == '"' {
				state = 2
				qidx = idx + 1
			}

		case 2: // look for ':'
			c := data[idx]
			// stop on any of these
			if c == ',' || c == '}' || c == ']' || c == '{' || c == '[' {
				state = 0
			}
			// this is the end object
			if c == ':' {
				state = 3
				//fmt.Printf("idx  %v sidx %v eidx %v ", idx+1, sidx, eidx)
				return idx + 1, sidx, qidx, eidx
			}

		case -1:
			break
		}
		idx += 1
		if idx >= ln {
			idx = -1
			return idx, 0, 0, 0
		}
	}
	return idx, 0, 0, 0
}

// look for next object  returns bounds of the current object
func GetNext(data []byte, sid, ln int) (sidx, eidx, edat, nidx, dt int) {
	idx := sid
	sidx = sid
	edat = sid
	state := 0
	skipobj := 0
	skiparr := 0
	dt = 0
	for state != -1 {
		switch state {
		case 0: // looking for start quote or a '[' or a '{'
			if data[idx] == byte('"') {
				dt = String
				state = 10
				sidx = idx
			} else if data[idx] == byte('[') {
				dt = Array
				state = 20
				sidx = idx
			} else if data[idx] == byte('{') {
				dt = Object
				state = 30
				sidx = idx
			} else if data[idx] == byte(',') {
				state = -1
				eidx = idx
				return idx, sidx, edat, eidx, dt

			} else if data[idx] == byte('-') {
				dt = Number
				sidx = idx
				state = 6
			} else if data[idx] >= byte('0') && data[idx] <= byte('9') {
				dt = Number
				sidx = idx
				state = 6
			} else if data[idx] == byte('t') || data[idx] == byte('f') {
				dt = Boolean
				sidx = idx
				state = 6
			}

		case 10: // check data after quote
			c := data[idx]
			// this is the endquote
			if c == '"' {
				state = 5 // look for comma or '}'
				edat = idx + 1
				eidx = idx
			}

		case 20: // look for ']'
			c := data[idx]
			// stop on any of these
			if c == '[' {
				skiparr += 1
			} else if c == ']' {
				if skiparr <= 0 {
					edat = idx + 1
					eidx = idx
					state = 5
				} else {
					skiparr -= 1
				}
			}

		case 30: // look for '}'
			c := data[idx]
			// stop on any of these
			if c == '{' {
				skipobj += 1
			} else if c == '}' {
				if skipobj <= 0 {
					edat = idx + 1
					eidx = idx
					state = 5
				} else {
					skipobj -= 1
				}
			}

		case 5: // check data after object
			c := data[idx]
			// stop on any of these
			if c == ',' || c == '}' {
				eidx = idx
				return idx, sidx, edat, eidx, dt
			}
		case 6: // check space after number
			c := data[idx]
			// stop on any of these
			if c == ',' || c == '}' || c == ']' || c == ' ' || c == '\n' {
				eidx = idx
				edat = idx
				if c == '\n' {
					eidx = idx - 1
				}
				return idx, sidx, edat, eidx, dt
			}

		case -1:
			break
		}
		idx += 1
		if idx >= ln {
			idx = -1
			return idx, 0, 0, 0, dt
		}
	}
	return idx, 0, 0, 0, dt
}

/*
Get - Receives data structure, and key path to extract value from.
Returns:
`value` - Pointer to original data structure containing key value, or just empty slice if nothing found or error
`dataType` -    Can be: `NotExist`, `String`, `Number`, `Object`, `Array`, `Boolean` or `Null`
`soff` - Offset from provided data structure where key value starts.
`offset` - Offset from provided data structure where key value ends. Used mostly internally, for example for `ArrayEach` helper.
`err` - If key not found or any other parsing issue it should return error. If key not found it also sets `dataType` to `NotExist`
Accept multiple keys to specify path to JSON value (in case of quering nested structures).
If no keys provided it will try to extract closest JSON value (simple ones or object/array), useful for reading streams or arrays, see `ArrayEach` implementation.

*/

func seekName(data []byte, name string, soff int, eoff int) (dataType int, soffr int, edat int, eoffr int, err error) {
	s := 0
	q := 0
	//n := 0
	sx := 0
	ex := 0
	nx := 0
	idx := soff
	dt := 0
	for idx >= 0 {
		idx, s, q, _ = GetName(data, idx, eoff)
		if idx > 0 {
			idx, sx, ex, nx, dt = GetNext(data, idx, eoff)
			if string(data[s+1:q-1]) == name {
				return dt, sx, ex, nx, nil
			}
		}
	}
	return 0, 0, 0, 0, fmt.Errorf("Path not found")
}

func FindPath(data []byte, keys string) (dataType int, soff int, edat int, eoff int, err error) {
	debug := false
	keya := strings.Split(keys, ".")
	soff = 0
	edat = 0
	dt := 0
	eoff = len(data)
	if len(keya) > 0 {
		for ki, k := range keya {
			if debug {
				fmt.Printf(" findpath dbgb0 => [%d] key [%v] \n", ki, k)
			}
			if err == nil {
				dt, soff, edat, eoff, err = seekName(data, k, soff, eoff) //(dataType int, soff int, eoff int, err error)
			} else {
				break
			}
		}
	}
	return dt, soff, edat, eoff, err
}

func main() {

	cfgFile := flag.String("file", "test.json", " input file to use")
	cfgOutFile := flag.String("output", "", " output file to use")
	cfgDir := flag.String("dir", "./", " optional dir ")
	//cfgKey := flag.String("key", "ip_address", " key to find")
	cfgVal := flag.String("val", "", " new value")
	cfgPath := flag.String("path", "servers.local.ip", "path to object")

	flag.Parse()

	cfile := fmt.Sprintf("%s/%s", *cfgDir, *cfgFile)
	cout := cfile
	if len(*cfgOutFile) > 0 {
		cout = fmt.Sprintf("%s/%s", *cfgDir, *cfgOutFile)
	}
	input, err := ioutil.ReadFile(cfile)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	//dt := 0
	//s := 0
	//e := 0
	//q := 0
	dt, s, e, q, err := FindPath(input, *cfgPath) // string("servers.local"))
	if err != nil {

		// 	fmt.Printf(" path [%v] %T found, data type %v s %v e %v q %v val [%s]\n", *cfgPath, *cfgPath, dt, s, e, q, string(input[s:e]))
		// } else {
		fmt.Printf(" path [%v] %T Not Found err [%v] q %v \n", *cfgPath, *cfgPath, err, q)

	}

	// ouput old string
	fmt.Println(string(input[s:e]))
	// replace value and write file
	if len(*cfgVal) > 0 {
		newval := []byte(*cfgVal)
		if dt == 1 {
			newval = []byte(strconv.Quote(string(newval)))
		}

		newtemp, _ := ReplaceBytes(input, s, e, newval)
		if err = ioutil.WriteFile(cout, newtemp, 0666); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	}
}
