--[[Check https://github.com/mtsmtsmts/Iot-home-controlfanlight]]--

thermo_Server = net.createServer(net.TCP) --Create TCP server

if thermo_Server then
    thermo_Server:listen(8099, function(conn) --Listen to the port
       dataParse(conn)
    end)
end

function dataParse(conn) --Process callback on receive data from client
    local substr 
    local cmdStr
    local cmd, equip
    local cmdString = {"webrequest","ceilingfan","counterlight","restart"} --array of equipment id words sent within HTTP GET call

    conn:on("receive", function(sck8099, data)
        print("DATA",data)
        if data ~=nil then
            parseData, dataStr = findData(data) --parse data sent
            cmd, equip = findCommand(parseData, cmdString)--find command and equipment id
            if dataStr ~=nil and dataStr ~= " " and equip ~=nil then --if data did not contained a matching equipment id
    
                if string.find(dataStr,'favicon.ico') then --Acting as filter --print("This is the favicon return! don't use it "..substr)
                else
                    print("dataStr",dataStr)
                    if string.find(dataStr,cmdString[1]) then --webrequest:%20counter%20light%20on 
                        if string.find(equip,cmdString[2]) then --'ceilingfan'
                            if cmd~=nil then
                                CeilingFan(cmd) --on
                            end
                        elseif string.find(equip, cmdString[3]) then --'counterlight'
                            if cmd~=nil then
                                CounterLight(cmd) --on
                                local UserSetTime = rtctime.epoch2cal(rtctime.get())--global for state of manual operation
                                local hour=UserSetTime["hour"]
                                if hour<8 then hour=hour+16 else hour=hour-8 end --correct for UTC-8 for pst
                                UserSetTime = (hour)*100 + UserSetTime["min"]
                                user_SetTime = UserSetTime --set global var, global used in setschedule()
                            end
                        end 
                    elseif string.find(dataStr,cmdString[4]) then--restart, set webIDE flag to true, mcu restarts and loads webIDE
                        sck8099:on("sent", function(conn) conn:close() end)
                        sck8099:close()
                        file.open("restart.lua","w+")
                        file.write(1)
                        file.close("restart.lua")                         
                        node.restart()   
                    end 
                end 
            end
        end 
    --sck8076:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n".."Detected: "..substr) --This is a simple web page response to be able to test it from any web browser 
    sck8099:on("sent", function(conn) conn:close() end)
    end)
end

function findData(data)--GET /webrequest:%20the%20counter%20light%20on HTTP/1.1
    local substr=string.sub(data,string.find(data,"GET /")+5,string.find(data,"HTTP/")-1) --Filter out GET and HTTP "webrequest:%20the%20counter%20light%20on"
    substr=string.lower(substr) --Set the string lower case to check it against 
    print(" ")
    print("SUBSTR",substr)
    local substr2 = substr
    if substr ~=nil and substr ~=" " then --if there was data between GET and HTTP
        if string.find(substr,":") then
            print(substr)
            substr=string.sub(substr,string.find(substr,":")+1) --Keep only the text part after the colon "%20the%20counter%20light%20on"
            print(substr)
            substr=string.gsub(substr,'%W+%d+',"") --remove non alpha chars "thecounterlighton" [IFTTT or GA likes to pass 'the' even though it is explicitly stated in IFTTT]
            print(substr)
            substr=string.gsub(substr,'(the)',"") --remove 'the' = "counterlighton"
            print(substr)
            substr=string.gsub(substr,"%s+","") --remove possible spaces
            print(substr)
        end
    end
    return substr, substr2 --returns nil if no data between GT and HTTP
end

function findCommand(str, array) --sent "ceilingfanon"
    local arrlen=StrLen(array)
    local n = 1
    local substr1, substr2
    print("arrlen",arrlen)
    while n <= arrlen do
        if string.find(str,array[n]) then --compare to equip id "ceilingfanon"
            local strlen = string.len(array[n])
            print("strlen",strlen)
            substr1=string.sub(str,string.find(str,array[n])+strlen) --remove the equipment id leaving command "on"
            print("SUBSTR1 cmd",substr1)
            substr2=string.sub(str,0,string.find(str,array[n])+strlen-1)--remove command "ceilingfan"
            print(substr2)
            n=strlen --break for loop
        end
        n=n+1
    end
    return substr1, substr2 --if not found returns nil
end

function SetTime() --nodemcu documents for NTP time
    sntp.sync({ "0.ca.pool.ntp.org", "1.ca.pool.ntp.org", "2.ca.pool.ntp.org", "3.ca.pool.ntp.org" },
        function(sec, usec, server, info)
            print(" ")
            print('sync', sec, usec, server)
            tm = rtctime.epoch2cal(rtctime.get())
            print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
            print("synch time done")
            print(" ")
        end,
        function()
            print(" ")
            print("synch time failed!")
            print(" ")
            print(" ")    
        end,
        1)
    Blink(150,0)
end
SetTime()
print ("Server code started")
