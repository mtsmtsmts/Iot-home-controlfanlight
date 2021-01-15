--[[Check https://github.com/mtsmtsmts/Iot-home-controlfanlight]]--
function checkRestart()
    local Restart    
    if file.open("restart.lua") == nil then	
        Restart = 0
        file.open("restart.lua","w+")	--if not created w+ will create it
        file.write(Restart)
        file.close("restart.lua")  
        file.open("restart.lua")    --open for read, default "r"
        print(file.read(1))
        StartApplication()     
    else
        Restart = file.read(1)  --grab the only char in the file     
        file.close("restart.lua")  
        print("Restart status:",Restart)     
            if Restart == "1" then	--if 1 do wWebIDE app else do application
                print("ide code starting")
                file.open("restart.lua","w+")
                file.write(0)
                file.close("restart.lua")
                StartIdeServer()
            else  
                print("Application code starting")          
                StartApplication()
            end
    end
end

function StartApplication()
    if file.open("ceilingfan.lua") == nil then
        print("ceilingfan deleted or renamed")
    else
        dofile("ceilingfan.lua")
        file.close("ceilingfan.lua")
    end  
    if file.open("counterlight.lua") == nil then
        print("counterlight deleted or renamed")
    else
        dofile("counterlight.lua")
        file.close("counterlight.lua")
    end         
    if file.open("ServerCode.lua") == nil then
        print("servercode.lua deleted or renamed")
    else
        dofile("ServerCode.lua")
        file.close("ServerCode.lua")
    end
end

function StartIdeServer()
    if file.open("ide.lua") == nil then
        print("ide deleted or renamed")
    else
        dofile("ide.lua")
        file.close("ide.lua")
    end  
    if file.open("IdeServercode.lua") == nil then
        print("ideServercode deleted or renamed")
    else
        dofile("IdeServercode.lua")
        file.close("IdeServercode.lua")
    end 
    tmr.create():alarm(600000, tmr.ALARM_SINGLE, function() node.restart() end) --10 minutes before reset
    local LEDstatus= gpio.read(4)      
    tmr.create():alarm(1000, tmr.ALARM_AUTO, function ()  --blink to notify IDE being used            
            LEDstatus = not LEDstatus
            gpio.write(4, LEDstatus and gpio.HIGH or gpio.LOW)
            end)     
end
checkRestart()
