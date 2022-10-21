package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"reflect"
	"strings"
	"time"
)

var CPATH string = "system_configs.json"

type SystemConfigs struct {
	SysInfo SysInfo `json:"sysInfo"`
	System  System  `json:"system"`
	Ess     Ess     `json:"ess"`
	Bms     Bms     `json:"bms"`
}
type StrArray []string
type SysInfo struct {
	SystemType           string    `json:"systemType_e"`
	SystemName           string    `json:"systemName_e"`
	SystemLastModified   time.Time `json:"systemLastModified"`
	SystemCreatedBy      string    `json:"systemCreatedBy"`
	SystemLastModifiedBy string    `json:"systemLastModifiedBy_e"`
	OutputFileName       string    `json:"outputFileName_e"`
	OutputFileCreated    time.Time `json:"outputFileCreated"`
	Actions              StrArray  `json:"actions_A"`
	SiteType             string    `json:"siteType_a"`
}
type System struct {
	Dnp3       int `json:"dnp3_e"`
	Historian  int `json:"historian_e"`
	Powercloud int `json:"powercloud_e"`
	Fleet      int `json:"fleet_manager_e"`
	Site       int `json:"site_e"`
	Ess        int `json:"ess_e"`
	Twins      int `json:"twins_e"`
}

type Ess struct {
	Ess      int    `json:"ess_e"`
	Ess_ip_1 string `json:"ess_ip_1_e"`
	Ess_ip_2 string `json:"ess_ip_2_e"`
	Bms      int    `json:"bms_e"`
	Bms_ip   string `json:"bms_ip_e"`
	Bms_name string `json:"bms_name_e"`
	Racks    []int  `json:"racks_e"`
	Pcs_ip   string `json:"pcs_ip_e"`
	Pcs      int    `json:"pcs_e"`
	Pcs_name string `json:"pcs_name_e"`
	Modules  []int  `json:"modules_e"`
}

type Bms struct {
	Bms      int    `json:"bms_e"`
	Bms_ip_1 string `json:"bms_ip_1_e"`
	Bms_ip_2 string `json:"bms_ip_2_e"`
	Racks    []int  `json:"racks_e"`
}

var (
	// ErrUnsupportedType is returned if the type is not implemented
	ErrUnsupportedType = errors.New("unsupported type")
)

func (sa *StrArray) UnmarshalJSON(data []byte) error {
	fmt.Printf(" func Unmarshall call \n")
	var jsonObj interface{}
	err := json.Unmarshal(data, &jsonObj)
	if err != nil {
		return err
	}
	switch obj := jsonObj.(type) {
	case string:
		*sa = StrArray([]string{obj})
		return nil
	case []interface{}:
		s := make([]string, 0, len(obj))
		for _, v := range obj {
			value, ok := v.(string)
			if !ok {
				return ErrUnsupportedType
			}
			s = append(s, value)
		}
		*sa = StrArray(s)
		return nil
	}
	return ErrUnsupportedType
}
func indexOf(arr []string, str string) int {
	var index int = -1
	for i, s := range arr {
		if s == str {
			index = i
		}
	}
	return index
}

func runPage() {
	h1 := func(w http.ResponseWriter, r *http.Request) {
		err := r.ParseForm()
		var filename interface{}
		jsonStr, _ := ioutil.ReadFile(CPATH)
		var jsonObj map[string]interface{}
		var configs SystemConfigs
		json.Unmarshal([]byte(jsonStr), &jsonObj)
		json.Unmarshal([]byte(jsonStr), &configs)
		fields := reflect.VisibleFields(reflect.TypeOf(configs))
		var outerkeys []string
		keys := make(map[string][]string)
		for _, field := range fields {
			field2 := string(field.Tag)[len(`json:"`) : len(string(field.Tag))-1]
			outerkeys = append(outerkeys, field2)
			innerfields := reflect.VisibleFields(field.Type)
			var temp []string
			for _, innerfield := range innerfields {
				innerfield2 := string(innerfield.Tag)[len(`json:"`) : len(string(innerfield.Tag))-1]
				temp = append(temp, innerfield2)
			}
			keys[field2] = temp
		}
		if err == nil {
			formVals := r.Form
			if len(formVals) > 0 {
				for _, key := range outerkeys {
					for _, key2 := range keys[key] {
						val := (jsonObj[key].(map[string]interface{}))[key2]
						if _, ok := formVals[key2[:len(key2)-2]]; ok { //key2[:len(key2)-2] is there because all of the editable fields have an _e at the end
							//TODO: figure out what to do about comparing values...This treats every formVal element as a list
							if fmt.Sprintf("%v", formVals[key2[:len(key2)-2]][0]) != fmt.Sprintf("%v", val) {
								(jsonObj[key].(map[string]interface{}))[key2] = formVals[key2[:len(key2)-2]][0]
							}
						}
					}
					if j := indexOf(keys[key], "outputFileName"); j != -1 {
						filename = keys[key][j]
						fmt.Println("filename set")
					}
				}
				file, _ := json.MarshalIndent(jsonObj, "", "    ")

				if filename == nil {
					filename = string(jsonObj["sysInfo"].(map[string]interface{})["outputFileName_e"].(string))
				}
				fmt.Println(filename)
				ioutil.WriteFile(string(filename.(string)), file, 0644)
				CPATH = string(filename.(string))
			}
		}
		jsonStr, _ = ioutil.ReadFile(CPATH)
		html := ""
		buildHTML(string(jsonStr), &html, outerkeys, keys)
		io.WriteString(w, html)

	}

	http.HandleFunc("/", h1)

	log.Fatal(http.ListenAndServe(":8080", nil))
}
func buildHTML(jsonStr string, htmlPage *string, outerkeys []string, keys map[string][]string) {
	//for this program to work, we need a json file in the form of a json object
	var jsonObj map[string]interface{}

	jsonObjErr := json.Unmarshal([]byte(jsonStr), &jsonObj)
	if jsonObjErr != nil {
		fmt.Println("Cannot convert file to json object")
		fmt.Println(jsonStr)
	} else { //dealing with a json object
		for _, key := range outerkeys {
			*htmlPage = *htmlPage + "<h1>" + key + `</h1><br><form method="put" enctype="application/x-www-form-urlencoded"><table>`
			for _, key2 := range keys[key] {
				val := (jsonObj[key].(map[string]interface{}))[key2]

				if strings.Contains(key2[len(key2)-2:], "_A") {
					val := (jsonObj[key].(map[string]interface{}))[key2[:len(key2)-2]]
					//aval := val.([]string)
					//fmt.Printf(" val %v %T key %v key2 %v \n", val, val, key, key2)
					*htmlPage += fmt.Sprintf(`<th><label for="%v">%v</label></th>`, key2[:len(key2)-2], key2[:len(key2)-2])
					*htmlPage += fmt.Sprintf(`<td><select  id="%v" name ="%v" `, key2[:len(key2)-2], key2[:len(key2)-2])
					//for i := 0; i < len(val); i++ {
					//	fmt.Printf(" val %T => %v \n", val[i], val[i])
					//}
					for _, k := range val.([]interface{}) {
						//fmt.Printf("ki %v k %v \n", ki, k)
						*htmlPage += fmt.Sprintf(`<option value="%v">%v</option>`, k, k)
					}
					//*htmlPage += fmt.Sprintf(`<option value="%v">%v</option>`, k, k)
					// 	//*htmlPage += fmt.Sprintf(`<option value="ncemc10">NCEMC10</option>`)
					// 	//*htmlPage += fmt.Sprintf(`<option value="brp10">BRP10</option>`)
					// 	//*htmlPage += fmt.Sprintf(`<option value="brp100">BRP100</option>`)
					//}
					*htmlPage += fmt.Sprintf(`</select> </td>`)
				} else if strings.Contains(key2[len(key2)-2:], "_a") {
					*htmlPage += fmt.Sprintf(`<th><label for="%v">%v</label></th>`, key2[:len(key2)-2], key2[:len(key2)-2])
					*htmlPage += fmt.Sprintf(`<td><select  id="%v" name ="%v" `, key2[:len(key2)-2], key2[:len(key2)-2])
					*htmlPage += fmt.Sprintf(`<option value="ncemc">NCEMC</option>`)
					*htmlPage += fmt.Sprintf(`<option value="ncemc10">NCEMC10</option>`)
					*htmlPage += fmt.Sprintf(`<option value="brp10">BRP10</option>`)
					*htmlPage += fmt.Sprintf(`<option value="brp100">BRP100</option>`)
					*htmlPage += fmt.Sprintf(`</select> </td>`)

				} else if strings.Contains(key2[len(key2)-2:], "_e") {
					*htmlPage += fmt.Sprintf(`<th><label for="%v">%v</label></th>`, key2[:len(key2)-2], key2[:len(key2)-2])
					*htmlPage += fmt.Sprintf(`<td><input type="text" id="%v" name ="%v" value="%v"><td>`, key2[:len(key2)-2], key2[:len(key2)-2], val)
				} else {
					*htmlPage += fmt.Sprintf(`<th>%v</th>`, key2)
					*htmlPage += fmt.Sprintf(`<td>%v</td>`, val)
				}

				*htmlPage = "<tr>" + *htmlPage + "</tr>"
			}
			*htmlPage = *htmlPage + `</table><br><input type="submit" name="submit" value="Submit"></form>`
		}

	}

	*htmlPage = `<html>` + *htmlPage + `</html>`
}

func main() {
	//for storing json data
	//var tempStr string
	//var tempBool bool
	//var tempJsonArray []interface{}
	//var tempJsonObj map[string]interface{}

	runPage()

}

//http://localhost:8080/?systemName=nremc_sitea&outputFileName=nremc_sitea.json&submit=Submit
//http://localhost:8080/?dnp3=0&historian=0&site=1&ess=10&twins=1&submit=Submit
//http://localhost:8080/?ess=10&ess_ip_1=172.30.40.10&ess_ip_2=172.30.20.10&bms=4&bms_ip=172.30.20.20&bms_name=CATL&racks=%5B4+4+5+7%5D&pcs_ip=172.30.30.20&pcs=2&pcs_name=PCS&modules=%5B1+2+2+2%5D&submit=Submit
