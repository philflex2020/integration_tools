package main

// tool to navigate a json text file
// we have to always use pointers because the data area always shifts
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
	debug := false
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("Unhandled JSON parsing error: %v, %s", r, string(d.Stack()))
		}
	}()

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
				fmt.Printf(" dbgb0 => key [%v] offset %d  ki %d data %v \n",
					k, offset, ki, string(data[offset])) // string(data[:20]))
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
				idx := bytes.Index(data[offset:], []byte(k))
				if debug {
					fmt.Printf(" ##1 k [%s] idx : %v  offset %d data [%s]\n",
						k, idx, offset, string(data[offset:]))

					fmt.Printf(" ##2 k [%s] idx %v  ln %d lk %d  ??? %d\n",
						k, idx, ln, lk, ln-(offset+idx+lk+2))
				}
				if idx := bytes.Index(data[offset:], []byte(k)); idx != -1 && (ln-(offset+idx+lk+2)) > 0 {
					offset += idx
					if debug {
						fmt.Printf(" ##2 k [%s] idx %d lk %d \n", k, idx, lk)
						fmt.Printf(" ##2a ##1 [%s] ##2 [%s] ##3 [%s] \n",
							string(data[offset+lk]), string(data[offset-1]), string(data[offset+lk+1]))
					}
					// this assumes that there is no space between "string":  fixed
					lkx := 1
					if data[offset+lk] == '"' && data[offset-1] == '"' {
						for data[offset+lk+lkx] != ':' {
							lkx += 1
						}
					}
					if data[offset+lk] == '"' && data[offset-1] == '"' && data[offset+lk+lkx] == ':' {

						offset += lk + lkx + 1
						nO := nextValue(data[offset:])

						if nO == -1 {
							return []byte{}, NotExist, -1, -1, errors.New("Malformed JSON error")
						}

						offset += nO
						if debug {
							fmt.Printf(" ##2b  looks good for [%v] running break \n", k)
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

	return value, dataType, offset, endOffset, nil
}

// ArrayEach is used when iterating arrays, accepts a callback function with the same return arguments as `Get`.
// Expects to receive array data structure (you need to `Get` it first). See example above.
// Underneath it just calls `Get` without arguments until it can't find next item.
func xArrayEach(data []byte, cb func(value []byte, dataType int, offset int, err error)) {
	if len(data) == 0 {
		return
	}

	offset := 1
	for true {
		v, t, _, o, e := Get(data[offset:])

		if t != NotExist {
			cb(v, t, o, e)
		}

		if e != nil {
			break
		}

		offset += o
	}
}

// GetNumber returns the value retrieved by `Get`, cast to a float64 if possible.
// The offset is the same as in `Get`.
// If key data type do not match, it will return an error.
func GetNumber(data []byte, keys ...string) (val float64, offset int, err error) {
	v, t, _, offset, e := Get(data, keys...)

	if e != nil {
		return 0, offset, e
	}

	if t != Number {
		return 0, offset, fmt.Errorf("Value is not a number: %s", string(v))
	}

	val, err = strconv.ParseFloat(string(v), 64)
	return
}

// GetBoolean returns the value retrieved by `Get`, cast to a bool if possible.
// The offset is the same as in `Get`.
// If key data type do not match, it will return error.
func GetBoolean(data []byte, keys ...string) (val bool, offset int, err error) {
	v, t, _, offset, e := Get(data, keys...)

	if e != nil {
		return false, offset, e
	}

	if t != Boolean {
		return false, offset, fmt.Errorf("Value is not a boolean: %s", string(v))
	}

	if v[0] == 't' {
		val = true
	} else {
		val = false
	}

	return
}

func main() {

	cfgFile := flag.String("file", "test.json", " file to use")
	cfgDir := flag.String("dir", "./", " optional dir ")
	cfgKey := flag.String("key", "ip_address", " key to find")
	cfgVal := flag.String("val", "127.0.0.1", " new value")

	flag.Parse()

	cfile := fmt.Sprintf("%s/%s", *cfgDir, *cfgFile)
	input, err := ioutil.ReadFile(cfile)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	//Get(data []byte, keys ...string) (value []byte, dataType int, soff int, offset int, err error) {

	temp, st, soff, off, err := Get(input, *cfgKey)

	//line := 0
	//instring := string(input)
	//temp := strings.Split(instring,"ip_address")
	fmt.Printf(" temp [%v] %T st %v soff [%v] off [%v] err [%v]\n ",
		string(temp), temp, st, soff, off, err)
	//func ReplaceBytes(data []byte, ix int, iy int, rep []byte) (value []byte, err error) {
	newval := []byte(*cfgVal)

	if st == 1 {
		newval = []byte(strconv.Quote(string(newval)))
	}
	newtemp, _ := ReplaceBytes(input, soff, off, newval)

	fmt.Printf(" newtemp [%v] \n ", string(newtemp))

	//      for _, item := range temp {
	//              fmt.Println("[",line,"]\t",item)
	//              line++
	//      }

	//output := bytes.Replace(input, []byte("replaceme"), []byte("ok"), -1)

	//if err = ioutil.WriteFile("modified.json", output, 0666); err != nil {
	//        fmt.Println(err)
	//        os.Exit(1)
	//}
}
