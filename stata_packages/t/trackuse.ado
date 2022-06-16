program trackuse, rclass 
*! Version: 4.1.0
*! Author:  Mark Lunt
*! Date:    November 10, 2017 @ 16:12:11

version 12

   syntax [anything], [progname(string) av(string) aid(string) options(string) ///
     package(string) tid(string)]

   if "`anything'" == "" & (("`progname'"=="") | ("`av'"=="") | ("`aid'"=="")) {
      window stopbox note "If you are not using trackuse for reconfiguration, you must set" ///
        "progname(), av() and aid()""`'"==""
      exit 100
   }

   if "`package'" == "" {
      local confname `progname'
   }
   else {
      local confname `package'
   }
   if "`anything'" != "" {
      local confname `anything'
   }

   // Only proceed if this program has not been tracked before, or if the delay time has elapsed, or
   // this is a reconfiguration
   
   if (("${`confname'_next_contact}" == "") | ///
     (${`confname'_next_contact}.0 <= clock(c(current_date) + c(current_time), "DMYhms")) | ///
     ("`anything'" != "")) {

      // Configuration for GA
      local url "https://personalpages.manchester.ac.uk/staff/mark.lunt/ga_sim.php?"
      local url "http://www.google-analytics.com/collect?"

      global TU_send_analytics 1
      global TU_send_aip 1       
      global TU_send_options 1
      global TU_delay_seconds 3600
      global TU_delay_minutes = $TU_delay_seconds / 60
      
      // Compulsory Parameters
      local v "v=1&"						// Collect protocol version
      if "`tid'" == "" {
         local tid "tid=UA-97135037-1&"		// Tracker id (account number) <------- my gmail account
      }
      else {
         local tid "tid=`tid'&"		// Tracker id (account number) anyone can use trackuse with their own account
      }
      local t "t=event&"					// Hit Type
      local el                    // event label: optional
      local ev                    // event value: optional

      // Additional Parameters
      local an "an=UsageTracker&"
      if "`av'" != "" {
         local av "av=`av'"
      }
      else {
         local av av=1.0&
      }
      if "`aid'" != "" {
         local aid "aid=`aid'&"
      }
      else {
         local aid "aid=NA&"
      }
  
      local confdir  = c(sysdir_personal)
      capture mkdir "`confdir'"
	
      tempname af cf

      if "`anything'" != "" {
         local conffile = "`confdir'`anything'.conf"
         capture confirm file "`conffile'"
         if _rc == 601 {
            window stopbox note "I cannot find `conffile'" "Nothing to configure"
            exit 601
         }
         else {
            // Read existing conf-file, if any, to get all parameters
            file open `cf' using "`conffile'", read text
            file read `cf' line
            while r(eof) == 0 {
               tokenize `line'
               local `1' `3'
               file read `cf' line
            }
            file close `cf'
            if "`delay_seconds'" != "" {
               global TU_delay_seconds `delay_seconds'
            }
            else {
               global TU_delay_seconds 3600
            }
            global TU_send_analytics `analytics'
            global TU_send_aip       `send_aip'
            global TU_send_options   `send_options'
            global TU_delay_minutes = round($TU_delay_seconds/60, 1)
            
            window control clear

            global TU_static_1 "Use the checkboxes below to select whether to send data about"
            global TU_static_2 "your use of `anything' to Google Analytics"
            global TU_static_3 "No personal data or any data that you are analysing will be sent."
            global TU_static_4 "Minimum time in minutes between contacts"
            global TU_ga_yes "exit 3000"

            window control static TU_static_1 10 10 200 10
            window control static TU_static_2 10 20 200 10
            window control static TU_static_3 10 30 200 10
  
            window control check "Send data"                          10 50 200 10 TU_send_analytics
            window control check "Include anonymised IP Address"      10 60 200 10 TU_send_aip
            window control check "Include options sent to `anything'" 10 70 200 10 TU_send_options
            window control edit                                       10 80  16  8 TU_delay_minutes 
            window control static TU_static_4 30 80 140 10 
      
            window control button "Save configuration" 30 95 60 15 TU_ga_yes
            capture noisily window dialog "Reconfiguring analytics for `anything'" . . 240 130
            if _rc == 3000 {
               global TU_delay_seconds = $TU_delay_minutes*60               
               // Read existing conf-file, if any, to get uuid
               // must exist as we've already tested for it above
               file open `cf' using "`conffile'", text read
               file read `cf' line
               local uuid
               while ("`uuid'" == "") & (r(eof) == 0) {
                  if regexm("`line'", "^uuid[ ]*:[ ]*([1234567890abcdef-]+)") {
                     local uuid = regexs(1)
                  }
                  file read `cf' line
               }
               file close `cf'
               
               // If there is no uuid found in that file, look in trackuse.uuid
               if "`uuid'" == "" {
                  local trackconf "`confdir'trackuse.uuid"
                  capture confirm file "`trackconf'"
                  if _rc != 601 {
                     file open `cf' using "`trackconf'", text read
                     file read `cf' line
                     local uuid
                     while ("`uuid'" == "") & (r(eof) == 0) {
                        if regexm("`line'", "^uuid[ ]*:[ ]*([1234567890abcdef-]+)") {
                           local uuid = regexs(1)
                        }
                        file read `cf' line
                     }
                     file close `cf'
                  }
                  // If there is still no uuid, create a new one
                  if "`uuid'" == "" {
                     uuidv4      
                     local uuid `r(uuid)'
                     file open `cf' using "`trackconf'", text write replace
                     file write `cf' "uuid         : `uuid'" _n
                     file close `cf'
                  }
               }
               // Write new conf-file
               file open `cf' using "`conffile'", write text replace
               file write `cf' "analytics     : $TU_send_analytics" _n
               file write `cf' "uuid          : `uuid'" _n
               file write `cf' "send_aip      : $TU_send_aip" _n
               file write `cf' "send_options  : $TU_send_options" _n
               file write `cf' "delay_seconds : $TU_delay_seconds" _n
               file close `cf'
      
               local cid "cid=`uuid'&"
               local ec "ec=`anything'&"   // event category: required
               local ea "ea=reconfigure&"  // event action: required
        
               capture file open `af' using "`url'`v'`tid'`cid'`t'`ec'`ea'`el'`ev'`an'`aid'`av'", read text
               local res = _rc
               if `res' == 0 {
                  file read `af' line
                  file close `af'
               }
            }
         }
      }
      else {
         // Event Parameters
         local conffile = "`confdir'`confname'.conf"
         local trackconf "`confdir'trackuse.uuid"
         local ec "ec=`confname'&"   // event category: required
         local ea "ea=install&"      // event action: required
    
         capture confirm file "`conffile'"
         if (_rc == 601) {
            // First run
            // ask if they will participate
            local evtype install
            local rc = _rc
            window control clear
            if "`package'" == "" {
               global TU_static_1 "We would like to keep track of how much use `progname' gets."
            }
            else {
               global TU_static_1 "We would like to keep track of how much use the programs in the `package' package get."
            }
            global TU_static_2 "Would you be willing to allow some information about your use"
            if "`package'" == "" {
               global TU_static_3 "of `progname' to be sent to Google Analytics each time you run it ?"
            }
            else {
               global TU_static_3 "of programs from the `package' package to be sent to Google Analytics each time you run it ?"
            }
            global TU_static_4 "You can select which data is sent on the next screen."
            global TU_static_5 "No personal data or any data that you are analysing will be sent."

            global TU_ga_yes "exit 3000"
            global TU_ga_no  "exit 3001"

            window control static TU_static_1 10 10 280 10
            window control static TU_static_2 10 20 280 10
            window control static TU_static_3 10 30 280 10
            window control static TU_static_4 10 40 280 10
            window control static TU_static_5 10 50 280 10

            window control button "Send Data"        10 70 60 15 TU_ga_yes
            window control button "Don't Send Data"  90 70 90 15 TU_ga_no
  
            capture noisily window dialog "Send analytics" . . 300 105
            if _rc == 3000 {
               // Agreed to send analytics
               // Specify data to be sent
               global TU_send_analytics 1
               global TU_send_aip 1       
               global TU_send_options 1
               global TU_delay_seconds 3600
               global TU_delay_minutes = $TU_delay_seconds / 60
                  
               window control clear
               global TU_static_1 "The name and version of the program being run will be sent."
               global TU_static_2 "Please check the boxes of any additional data you are happy to send."
               global TU_static_4 "Minimum time in minutes between contacts"

               window control static TU_static_1 10 10 200 10
               window control static TU_static_2 10 20 220 10

               window control check "Anonymised IP Address"      10 40 200 10 TU_send_aip
               window control check "Options sent to `progname'" 10 50 200 10 TU_send_options
               window control edit                               10 60  16  8 TU_delay_minutes 
               window control static TU_static_4 30 60 140 10 

               window control button "Save configuration" 30 80 60 15 TU_ga_yes

               capture noisily window dialog "Saving analytics configuration" . . 240 120

               if _rc == 3000 {
                  capture confirm file "`trackconf'"
                  if _rc != 601 {
                     file open `cf' using "`trackconf'", text read
                     file read `cf' line
                     local uuid
                     while ("`uuid'" == "") & (r(eof) == 0) {
                        if regexm("`line'", "^uuid[ ]*:[ ]*([1234567890abcdef-]+)") {
                           local uuid = regexs(1)
                        }
                        file read `cf' line
                     }
                     file close `cf'
                  }
                  // If there is no uuid, create a new one
                  if "`uuid'" == "" {
                     uuidv4      
                     local uuid `r(uuid)'
                     file open `cf' using "`trackconf'", text write replace
                     file write `cf' "uuid         : `uuid'" _n
                     file close `cf'
                  }
                  file open `cf' using "`conffile'", text write replace
                  file write `cf' "analytics     : 1" _n
                  file write `cf' "uuid          : `uuid'" _n
                  file write `cf' "send_aip      : $TU_send_aip" _n
                  file write `cf' "send_options  : $TU_send_options" _n
                  file write `cf' "delay_seconds : $TU_delay_seconds" _n
                  file close `cf'
                  local send_aip $TU_send_aip
                  local send_options $TU_send_options

                  window stopbox note "Thank You" ///
                    `"You can change what is sent by editing "`conffile'""' ///
                    `"If you delete "`conffile'", you will be asked to reconfigure"'
               }
      
               // App parameters
               local an "an=UsageTracker&"
               local av "av=`av'"
               local aid "aid=`aid'&"
               local cid "cid=`uuid'&"  		// Client id
      
               capture file open `af' using "`url'`v'`tid'`cid'`t'`ec'`ea'`el'`ev'`an'`aid'`av'", read text
               local res = _rc
               if `res' == 0 {
                  file read `af' line
                  file close `af'
               }
            }
            else {
               // Did not agree
               file open `cf' using "`conffile'", text write replace
               file write `cf' "analytics : 0" _n
               file close `cf'
               exit 
            }
         }
         else {
            // Config file exists, so we are running the program, not installing it
            file open `cf' using "`conffile'", read text
            file read `cf' line
            if "`line'" == "analytics : 0" {
               file close `cf'
               exit
            }
            else {
               file read `cf' line
               while r(eof) == 0 {
                  tokenize `line'
                  local `1' `3'
                  file read `cf' line
               }
               file close `cf'
               if "`delay_seconds'" != "" {
                  global TU_delay_seconds `delay_seconds'
               }
               else {
                  global TU_delay_seconds 3600
               }
               // App parameters
               local an "an=UsageTracker&"
               local av "av=`av'"
               local aid "aid=`aid'&"
               local cid "cid=`uuid'&"
               if "`send_aip'" == "1" {
                  local aid `aid'aip=1&
               }
               if "`send_options'" == "1" {
                  local el el=`options'&
               }
            }
         }

         local ea "ea=run&"

         capture file open `af' using "`url'`v'`tid'`cid'`t'`ec'`ea'`el'`ev'`an'`aid'`av'", read text
         local res = _rc
         if `res' == 0 {
            file read `af' line
            file close `af'
         }
      }
      global `confname'_next_contact = clock(c(current_date) + c(current_time), "DMYhms") + $TU_delay_seconds*1000
   }
   
end
