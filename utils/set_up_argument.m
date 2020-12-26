function command = set_up_argument(default_command, inputargument, now_soft)
command = '';
if (now_soft ==1)
    command = append(default_command,' ', inputargument);
elseif(now_soft ==2)
    command = append(default_command); 
end
end
