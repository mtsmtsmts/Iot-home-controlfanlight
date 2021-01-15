--[[Check https://github.com/mtsmtsmts/Iot-home-controlfanlight]]--
function CeilingFan(what) --called from dataParse() after http request
    local GPIOOff = 5 --see init for pin defs
    local GPIOOnLow = 6 
    local GPIOMed = 7 
    local GPIOHigh = 8 
    local GPIOLightOnOff = 1
    local GPIOLightDim = 2
    local DelayTime  =1500 --delay in us
    local DelayTimeDimmer = 3000 --delay in us
    local EnableRelay = 1
    local nEnableRelay = 0
    local FAST=30 --blink period in ms
    local SLOW=140 --blink period in ms
    local BlinkSpeed = FAST
    local DataWRITE
    local Timer1 = tmr.create()
    switch_pins = {12 , 5 , 4 , 15}  

    print(switch_pins[2])
    
    print("Got "..what)
    if what =="on" or what =="on%20the" or what =="1" or what =="low" or what =="on%20low"then --turn the fan 'on' or 'low'
        DataWRITE = GPIOOnLow
        print ("Output on Low 1")
    elseif what =="off" or what =="off%20the" then --turn the fan 'off'
        DataWRITE = GPIOOff
        print ("Output off")
    elseif what =="2" or what =="medium" or what =="onmedium" then --set the fan to '2'
        DataWRITE = GPIOMed
        print ("Output Med 2")
    elseif what =="3" or what =="high" or what =="onhigh" then --set the fan to '3'
        DataWRITE = GPIOHigh
       print ("Output high 3")
    elseif what =="lighton" or what =="lightoff" or what =="light" then --toggle the light 
        DataWRITE = GPIOLightOnOff
        print ("Output light toggle")
    elseif what =="lightdim" then --dim the light
        DataWRITE = GPIOLightDim
        DelayTime = DelayTimeDimmer
        print ("Output light Dim")  
    else
        DataWRITE = nil
        print ("No matching command")
        BlinkSpeed = SLOW
    end 
    
    if DataWRITE then
        gpio.write(DataWRITE,EnableRelay); --enable button 'press' for about 1.5 seconds
        Timer1:alarm(DelayTime, tmr.ALARM_SINGLE, function () gpio.write(DataWRITE, nEnableRelay); Timer1:unregister() end)  
    end
    Blink(BlinkSpeed, 0)
end

function Blink(speed, BlinkForever)
    local LED=4
    local numBlinks = 4
    
    speed = speed * 1000 --time in us
    if BlinkForever ~=0 and BlinkForever ~= nil then
        numBlinks = 0 --0 blinks non stop
    end    
    gpio.serout(LED,gpio.LOW,{30000,speed},numBlinks, 1) --uses HW Timer consecutive calls with crash
    
 --[[  
    local Timer2 = tmr.create()
    local num_Blinks = 8
    local LEDstatus = gpio.read(LED)  
    if not Timer2:alarm(speed, 1, function (t)
            LEDstatus = not LEDstatus
            gpio.write(LED, LEDstatus and gpio.HIGH or gpio.LOW)
            --gpio.serout(1,gpio.HIGH,{5000,995000},100, function() print("done") end)  --will this work to toggle the pin ?
            if BlinkForever ~= 1 then
                num_Blinks = num_Blinks - 1
                if num_Blinks < 1 then
                    gpio.write(LED, 1) --turn off
                    num_Blinks = 0
                    t:unregister() 
                end               
            end
        end)
    then print("can't blink, timer used")
    end  ]]-- 
end
print("fan code started")
