--[[Check https://github.com/mtsmtsmts/Iot-home-controlfanlight]]--
user_SetTime=nil --not local, used in dataparse()

function CounterLight(what)
    local GPIOLightOnOff = 12 --see init for pin defs
    local EnableRelay = 1
    local nEnableRelay = 0
    local FAST=30 --blink period in ms
    local SLOW=140 --blink period in ms
    local BlinkSpeed = FAST

    print("Got "..what)
    if what =="on" or what =="on%20the" then 
        if gpio.read(GPIOLightOnOff) ~= EnableRelay then --if not already enabled	
            gpio.write(GPIOLightOnOff,EnableRelay);	--enable
            print ("counter light on")
            Blink(BlinkSpeed, 0)
        end
            
    elseif what =="off" or what =="off%20the" then
        if gpio.read(GPIOLightOnOff) ~= nEnableRelay then
            gpio.write(GPIOLightOnOff,nEnableRelay);
            print ("counter light off")
            Blink(BlinkSpeed, 0)
        end
    else
        DataWRITE = nil
        print ("No matching command")
        BlinkSpeed = SLOW
        Blink(BlinkSpeed, 0)
    end 
end

function setSchedule() 
    local UserSetTime = user_SetTime --grab global var
    local Tm = {0000, 0900, 1700, 2000} --on,off times --change to global for User access in UX
    local St = {"off","on", "off","on"}--pin state for on,off times--change to global for User access in UX
    local Sch={Tm,St}--Sch[x][y]
    local UTCtime = rtctime.epoch2cal(rtctime.get()) --returns UTC time (+8 hours from pst)
    local hour=UTCtime["hour"]
        if hour<8 then hour=hour+16 else hour=hour-8 end --correct for UTC-8 for pst
    local timenow = (hour)*100 + UTCtime["min"]
    local Sch_index=1
    
    if StrLen(Tm) == StrLen(St) then --useful for future imp of setting schedule remotely
        while Sch_index <= StrLen(Tm) and timenow >= Sch[1][Sch_index] do             
            Sch_index = Sch_index + 1                 
        end        
        Sch_index = Sch_index - 1 --because I'm not a great coder 
        
        print("timenow:",timenow)
        print("Sent to pin:",Sch[1][Sch_index],Sch[2][Sch_index]) 
        print("user set?:",UserSetTime) 
        
        if UserSetTime ~= nil then -- if nil do nothing, lights turned on manually, ignore till next scheduled event
            if UserSetTime < Sch[1][Sch_index] then --compare time manually dis/en-abled to the currently pointed to index in the array
                UserSetTime = nil --reset
                print("user set nil:",UserSetTime)
            elseif UserSetTime > timenow then    --clock rolled over past midnight?
                UserSetTime = 0000            
                print("user set 0000:", UserSetTime)  
            end
        else
            CounterLight(Sch[2][Sch_index])
        end
    end
    user_SetTime = UserSetTime --return global var
end

function doSchedule()
    local timer1 = tmr.create()
    local UTCtime = rtctime.epoch2cal(rtctime.get())
    local secDelta
    if UTCtime["year"] > 1970 then --RTC inits with 1970 
        secDelta = (60 - UTCtime["sec"])*1000 --adjust timer interrupt to occur on the minute in case RTC starts to drift
        setSchedule()
    else      
        secDelta = 5000 --check again in 5 seconds if time not set from NPT, if never set schedule cannot operate
    end
    timer1:alarm(secDelta, tmr.ALARM_SINGLE, 
        function(t) 
            doSchedule()
            t:unregister()
        end) 
   -- print(" ")
    --print(string.format("%04d/%02d/%02d %02d:%02d:%02d", UTCtime["year"], UTCtime["mon"], UTCtime["day"], UTCtime["hour"], UTCtime["min"], UTCtime["sec"])) --string causes memory overload
    print("new secDelta",secDelta)
       
end

function StrLen(Arr)
    local getN=0
    for n in pairs(Arr) do 
        getN = getN + 1 
    end
    return getN
end
doSchedule()
print ("counter light code started")
file.close("counterlight.lua")
