ide_Server = net.createServer(net.TCP) --Create TCP server
if ide_Server then
  ide_Server:listen(8099, function(ideconn) --Listen to the port 80
    editor(ideconn) 
    end)
end    
print ("Server code started")
