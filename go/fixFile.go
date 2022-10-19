package main

// p wilshire
// 10_17_2022
//   10_19_2022 made it recursive  system.target.ip
// replace a named field in a json file
// used in the integration_tools utility

import (
	"bytes"
	"errors"
	"fmt"
	d "runtime/debug"
	"strconv"

	//"log"
	//"unsafe"
	"flag"
	"io/ioutil"
	"os"
	"strings"
)

func ReplaceBytes(data []byte, ix int, iy int, rep []byte) (value []byte, err error) {
	return append(data[:ix], append(rep, data[iy:]...)...), nil
}

// Find position of next character which is not ' ', ',', '}' or ']'
func nextValue(data []byte) (offset int) {
	for true {
		if len(data) == offset {
			return -1
		}
		if data[offset] != ' ' && data[offset] != '\n' && data[offset] != '\r' && data[offset] != 9 && data[offset] != ',' && data[offset] != '}' && data[offset] != ']' {
			return
		}
		offset++
	}
	return -1
}

// Tries to find the end of string
// Support if string contains escaped quote symbols.
func stringEnd(data []byte) int {
	i := 0

	for true {
		sIdx := bytes.IndexByte(data[i:], '"')

		if sIdx == -1 {
			return -1
		}
		i += sIdx + 1
		// If it just escaped \", continue
		if i > 2 && data[i-2] == '\\' {
			continue
		}
		break
	}
	return i
}

// Find end of the data structure, array or object.
// For array openSym and closeSym will be '[' and ']', for object '{' and '}'
// Know about nested structures
func trailingBracket(data []byte, openSym byte, closeSym byte) int {
	level := 0
	i := 0
	ln := len(data)

	for true {
		if i >= ln {
			return -1
		}
		c := data[i]
		// If inside string, skip it
		if c == '"' {
			//sFrom := i
			i++
			se := stringEnd(data[i:])
			if se == -1 {
				return -1
			}
			i += se - 1
		}
		if c == openSym {
			level++
		} else if c == closeSym {
			level--
		}
		i++
		if level == 0 {
			break
		}
	}
	return i
}

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

// look for "<string>": pattern
func GetName(data []byte, sid, ln int) (sidx, eidx, nidx, pidx int) {
	//fmt.Printf("GetName sid %v -", sid)
	if sid < 0 {
		return -1, 0, 0, 0
	}
	idx := sid
	qidx := 0
	//ln := len(data)
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

// look for next object  skip {[
func GetNext(data []byte, sid, ln int) (sidx, eidx, nidx int) {
	//fmt.Printf("GetNext sid %v -", sid)
	idx := sid
	sidx = sid
	//ln := len(data)
	//fmt.Printf("GetNext sid %v len %v -", sid, ln)

	state := 0
	skipobj := 0
	skiparr := 0
	for state != -1 {
		switch state {
		case 0: // looking for start quote or a '[' or a '{'
			if data[idx] == byte('"') {
				state = 10
				sidx = idx
			} else if data[idx] == byte('[') {
				state = 20
				sidx = idx
			} else if data[idx] == byte('{') {
				state = 30
				sidx = idx
			} else if data[idx] == byte(',') {
				state = -1
				eidx = idx
				//fmt.Printf("#1 idx %v sidx %v eidx %v\n", idx, sidx, eidx)

				return idx, sidx, eidx
			} else if data[idx] == byte('-') {
				sidx = idx
				state = 6
			} else if data[idx] >= byte('0') && data[idx] <= byte('9') {
				sidx = idx
				state = 6
			}

		case 10: // check data after quote
			c := data[idx]
			// this is the endquote
			if c == '"' {
				state = 5 // look for comma or '}'
				eidx = idx
			}

		case 20: // look for ']'
			c := data[idx]
			// stop on any of these
			if c == '[' {
				skiparr += 1
			} else if c == ']' {
				if skiparr <= 0 {
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
				//fmt.Printf("#2 sidx %v eidx %v\n", sidx, eidx)
				return idx, sidx, eidx
			}
		case 6: // check space after number
			c := data[idx]
			// stop on any of these
			if c == ',' || c == '}' || c == ' ' || c == '\n' {
				eidx = idx
				//fmt.Printf("#3 sidx %v eidx %v\n", sidx, eidx)
				return idx, sidx, eidx
			}

		case -1:
			break
		}
		idx += 1
		if idx >= ln {
			idx = -1
			return idx, 0, 0
		}
	}
	return idx, 0, 0
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
func Get(data []byte, keys ...string) (value []byte, dataType int, soff int, offset int, err error) {
	debug := true
	retoff := 0
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("Unhandled JSON parsing error: %v, %s", r, string(d.Stack()))
		}
	}()
	fmt.Printf(" data ##1 [%p]\n", &data)

	ln := len(data)
	// if len(keys) == 1 and keys contains "|" as in "assets|ess|variables"
	// then create a new keys with the original object split.
	if len(keys) == 1 {
		if strings.Contains(keys[0], "|") {
			keys = strings.Split(keys[0], "|")
		} else if strings.Contains(keys[0], ".") {
			keys = strings.Split(keys[0], ".")
		}
	}

	if len(keys) > 0 {
		for ki, k := range keys {
			if debug {
				fmt.Printf(" data ##xx [%p] offset %v len %v \n", &data, offset, ln)

				fmt.Printf(" dbgb0 => key [%v] offset %d  ki %d data %v \n",
					k, offset, ki, string(data[offset:ln])) // string(data[:20]))
			}
			lk := len(k)

			if ki > 0 {
				// Only objects can have nested keys
				if data[offset] == '{' {
					// Limiting scope for the next key search
					endOffset := trailingBracket(data[offset:], '{', '}')
					if debug {
						fmt.Printf(" dbgb1 { => offset: %v end: %v\n", offset, offset+endOffset)
					}
					data = data[offset : offset+endOffset]
					offset = 0
				} else if data[offset] == '[' {
					// Limiting scope for the next key search
					endOffset := trailingBracket(data[offset:], '[', ']')
					if debug {
						fmt.Printf(" dbgb1 [ => offset:%v endoffset:%v \n", offset, offset+endOffset)
					}
					data = data[offset : offset+endOffset]
					offset = 0
				} else {
					return []byte{}, NotExist, -1, -1, errors.New("Key path not found")
				}
			}

			for true {
				// idx := bytes.Index(data[offset:], []byte(k))
				// if debug {
				// 	fmt.Printf(" ##1 k [%s] idx : %v  offset %d data [%s]\n",
				// 		k, idx, offset, string(data[offset:]))

				// 	fmt.Printf(" ##2 k [%s] idx %v  ln %d lk %d  ??? %d\n",
				// 		k, idx, ln, lk, ln-(offset+idx+lk+2))
				// }
				//if idx := bytes.Index(data[offset:], []byte(k)); idx != -1 && (ln-(offset+idx+lk+2)) > 0 {
				if idx, _, _, _ := GetName(data, offset, len(data)); idx != -1 && (ln-(offset+idx+lk+2)) > 0 {
					offset += idx
					if debug {
						fmt.Printf(" ##2 k [%s] idx %d lk %d \n", k, idx, lk)
						fmt.Printf(" ##2a ##1 [%s] ##2 [%s] ##3 [%s] \n",
							string(data[offset+lk]), string(data[offset-1]), string(data[offset+lk+1]))
					}
					// this assumes that there is no space between "string":
					// fixed using the following code
					lkx := 1
					// if data[offset+lk] == '"' && data[offset-1] == '"' {
					// 	for data[offset+lk+lkx] != ':' {
					// 		lkx += 1
					// 	}
					// }
					if data[offset+lk] == '"' && data[offset-1] == '"' && data[offset+lk+lkx] == ':' {

						offset += lk + lkx + 1
						nO := nextValue(data[offset:])

						if nO == -1 {
							return []byte{}, NotExist, -1, -1, errors.New("Malformed JSON error")
						}

						offset += nO
						retoff += offset
						if debug {
							fmt.Printf(" ##2b  looks good for [%v] running break, offset %v \n", k, offset)
						}
						break
					} else {
						offset++
					}
				} else {
					str := fmt.Sprintf("Key [%v] path not found", keys)
					return []byte{}, NotExist, -1, -1, errors.New(str)
				}
			}
		}
	} else {
		nO := nextValue(data[offset:])

		if nO == -1 {
			return []byte{}, NotExist, -1, -1, errors.New("Malformed JSON error")
		}

		offset = nO
	}

	endOffset := offset

	// if string value
	if data[offset] == '"' {
		dataType = String
		if idx := stringEnd(data[offset+1:]); idx != -1 {
			endOffset += idx + 1
		} else {
			return []byte{}, dataType, offset, offset, errors.New("Value is string, but can't find closing '\"' symbol")
		}
	} else if data[offset] == '[' { // if array value
		dataType = Array
		// break label, for stopping nested loops
		endOffset = trailingBracket(data[offset:], '[', ']')

		if endOffset == -1 {
			return []byte{}, dataType, offset, offset, errors.New("Value is array, but can't find closing ']' symbol")
		}

		endOffset += offset
	} else if data[offset] == '{' { // if object value
		dataType = Object
		// break label, for stopping nested loops
		endOffset = trailingBracket(data[offset:], '{', '}')

		if endOffset == -1 {
			return []byte{}, dataType, offset, offset, errors.New("Value looks like object, but can't find closing '}' symbol")
		}

		endOffset += offset
	} else {
		// Number, Boolean or None
		end := bytes.IndexFunc(data[endOffset:], func(c rune) bool {
			return c == ' ' || c == '\n' || c == ',' || c == '}' || c == ']' || c == 9
		})

		if data[offset] == 't' || data[offset] == 'f' { // true or false
			dataType = Boolean
		} else if data[offset] == 'u' || data[offset] == 'n' { // undefined or null
			dataType = Null
		} else {
			dataType = Number
		}

		if end == -1 {
			return []byte{}, dataType, offset, offset, errors.New("Value looks like Number/Boolean/None, but can't find its end: ',' or '}' symbol")
		}

		endOffset += end
	}

	value = data[offset:endOffset]

	// Strip quotes from string values
	if dataType == String {
		value = value[1 : len(value)-1]
	}

	if dataType == Null {
		value = []byte{}
	}
	retend := retoff + (endOffset - offset)
	fmt.Printf(" retoff = [%v] retend [%v]\n", retoff, retend)
	fmt.Printf(" data [%v]\n", string(data[retoff:retend]))
	fmt.Printf(" data ## ##[%p]\n", &data)
	fmt.Printf(" offset %v end %v value [%v]\n", offset, endOffset, string(data[offset:endOffset]))
	return value, dataType, retoff, retend, nil
}

func seekName(data []byte, name string, soff int, eoff int) (dataType int, soffr int, eoffr int, err error) {
	s := 0
	q := 0
	//n := 0
	sx := 0
	nx := 0
	idx := soff
	for idx >= 0 {
		idx, s, q, _ = GetName(data, idx, eoff)
		if idx > 0 {
			fmt.Printf(" name [%v] ", string(data[s:q]))
			//idx = n
			//fmt.Printf(" next idx %v \n", idx)
		}

		//idx, s, n = GetNext(input, idx)
		if idx > 0 {
			idx, sx, nx = GetNext(data, idx, eoff)
			fmt.Printf(" data [%v] \n", string(data[sx:nx]))
		}
		if string(data[s+1:q-1]) == name {
			fmt.Printf(" found name [%v] ", string(data[s:q]))
			return idx, sx, nx, nil
		}

	}
	return -1, 0, 0, nil

}

func FindPath(data []byte, keys string) (dataType int, soff int, eoff int, err error) {
	debug := true
	//	var keya = string
	//	if strings.Contains(keys, ".") {
	keya := strings.Split(keys, ".")
	//	}
	soff = 0
	eoff = len(data)
	if len(keya) > 0 {
		for ki, k := range keya {
			if debug {

				fmt.Printf(" findpath dbgb0 => [%d] key [%v] \n", ki, k)
				//k, offset, ki, string(data[offset:ln])) // string(data[:20]))
			}
			if ki < 3 {
				_, soff, eoff, _ = seekName(data, k, soff, eoff) //(dataType int, soff int, eoff int, err error)
				fmt.Printf(" findpath 2 dbgb0 => [%d] key [%v]  soff %v eoff %v data [%v] \n", ki, k, soff, eoff, string(data[soff:eoff]))
			}
		}
	}

	return 0, 0, 0, nil
}
func main() {

	cfgFile := flag.String("file", "test.json", " input file to use")
	//cfgOutFile := flag.String("output", "dummy", " output file to use")
	cfgDir := flag.String("dir", "./", " optional dir ")
	cfgKey := flag.String("key", "ip_address", " key to find")
	cfgVal := flag.String("val", "127.0.0.1", " new value")
	cfgPath := flag.String("path", "", " path to object")

	flag.Parse()

	cfile := fmt.Sprintf("%s/%s", *cfgDir, *cfgFile)

	input, err := ioutil.ReadFile(cfile)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	fmt.Printf(" data ## ##[%p]\n", &input)
	idx := 0
	s := 0
	q := 0
	n := 0
	idx, s, q, _ = FindPath(input, string("servers.local.ip"))
	idx = 0
	s = 0
	q = 0
	n = 0

	for idx >= 0 {
		idx, s, q, n = GetName(input, idx, len(input))
		if idx > 0 {
			fmt.Printf(" name [%v] ", string(input[s:q]))
			//idx = n
			//fmt.Printf(" next idx %v \n", idx)
		}
		//idx, s, n = GetNext(input, idx)
		if idx > 0 {
			idx, s, n = GetNext(input, idx, len(input))
			fmt.Printf(" data [%v] \n", string(input[s:n]))
		}

	}
	os.Exit(1)

	//Get(data []byte, keys ...string) (value []byte, dataType int, soff int, offset int, err error) {
	//temp
	if *cfgPath != "" {
		key := fmt.Sprintf("%s|%s", *cfgPath, *cfgKey)
		//temp, st, soff, off, err := Get(input, *cfgKey, *cfgPath)
		temp, st, soff, off, err := Get(input, key)

		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		fmt.Printf(" temp [%s] soff %v off %v  data [%v] \n", temp, soff, off, string(input[soff:off]))
		fmt.Printf(" input [%p]\n", &input)

		newval := []byte(*cfgVal)

		if st == 1 {
			newval = []byte(strconv.Quote(string(newval)))
		}
		newtemp, _ := ReplaceBytes(input, soff, off, newval)
		if err = ioutil.WriteFile(cfile, newtemp, 0666); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

	} else {
		_, st, soff, off, err := Get(input, *cfgKey)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		newval := []byte(*cfgVal)

		if st == 1 {
			newval = []byte(strconv.Quote(string(newval)))
		}
		newtemp, _ := ReplaceBytes(input, soff, off, newval)
		if err = ioutil.WriteFile(cfile, newtemp, 0666); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

	}

	//line := 0
	//instring := string(input)
	//temp := strings.Split(instring,"ip_address")
	//fmt.Printf(" temp [%v] %T st %v soff [%v] off [%v] err [%v]\n ",
	//	string(temp), temp, st, soff, off, err)
	//func ReplaceBytes(data []byte, ix int, iy int, rep []byte) (value []byte, err error) {

	//fmt.Printf(" newtemp [%v] \n ", string(newtemp))

	//      for _, item := range temp {
	//              fmt.Println("[",line,"]\t",item)
	//              line++
	//      }

	// if *cfgOutFile != "dummy" {
	// 	if err = ioutil.WriteFile(*cfgOutFile, newtemp, 0666); err != nil {
	// 		fmt.Println(err)
	// 		os.Exit(1)
	// 	}
	// } else {
	// 	if err = ioutil.WriteFile(cfile, newtemp, 0666); err != nil {
	// 		fmt.Println(err)
	// 		os.Exit(1)
	// 	}

	// }
}
