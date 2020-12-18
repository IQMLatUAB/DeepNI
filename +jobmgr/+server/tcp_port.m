function port = tcp_port
%TCP_PORT Return the TCP port number used by the job server.
load('jobmgr/netsrv/server');
port = str2num(server{2});
end
