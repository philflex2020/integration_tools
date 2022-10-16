package main

 import (
 //        "bytes"
         "fmt"
         "io/ioutil"
         "os"
	"strings"
 )

 func main() {

         input, err := ioutil.ReadFile("test.json")
         if err != nil {
                 fmt.Println(err)
                 os.Exit(1)
         }
         temp:= Get(input,"ip_address")

         //line := 0
         //instring := string(input)
         //temp := strings.Split(instring,"ip_address")
         fmt.Printf(" temp [%v] %T\n ", temp, temp)
//	for _, item := range temp {
//        	fmt.Println("[",line,"]\t",item)
//        	line++
//    	}

         //output := bytes.Replace(input, []byte("replaceme"), []byte("ok"), -1)

         //if err = ioutil.WriteFile("modified.json", output, 0666); err != nil {
         //        fmt.Println(err)
         //        os.Exit(1)
         //}
 }
