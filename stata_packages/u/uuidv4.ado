program uuidv4, rclass 
*! Version: 3.0.3
*! Author:  Mark Lunt
*! Date:    April 12, 2017 @ 17:24:59

version 12

syntax 

  quietly {
    tempfile temp
    file open tf using "`temp'", write text replace
    local now   `c(current_time)'
    local today `c(current_date)'
    local comp  `c(hostname)'
    local me    `c(username)'
    file write tf "`now'" _n "`today'" _n "`comp'" _n "`me'" _n
    file close tf
    checksum "`temp'"
    local seed = mod(`r(checksum)', 2^31)
    local oseed `c(seed)'
    set seed `seed'
    
    matrix rints = (0,0,0,0,0,0,0,0)
    local i = 1
    while `i' <= 8 {
      if `i' == 4 {
        local i 6
      }
      local ran_int = int(65536*runiform())
      matrix rints[1,`i++'] = `ran_int'
    
    }
    local ran_int = int(4096*runiform())
    matrix rints[1,4] = `ran_int' + 16384
    local ran_int = int(16384*runiform())
    matrix rints[1,5] = `ran_int' + 32768
    
    local uuid
    foreach num of numlist 1/8 {
      if inrange(`num',3,6) {
        local uuid `uuid'-
      }
      local ninten = el("rints", 1, `num')
      inbase 16 `ninten'
      local ninthex = r(base)
      while length("`ninthex'") < 4 {
        local ninthex 0`ninthex'
      }
      local uuid `uuid'`ninthex'
    }
    
    set seed `oseed'
  }
  di as result "`uuid'"
  return local uuid  "`uuid'"
end
