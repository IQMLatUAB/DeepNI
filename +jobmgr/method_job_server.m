function r = method_job_server(run_opts, configs, config_hashes, run_names)
% METHOD_JOB_SERVER Run using the job server
    load('jobmgr/netsrv/server');
    M = numel(configs);
    r = cell(M, 1);

    fprintf('Job Manager: Using the job server to run %i items\n', M);

    % Queue each job
    for a = 1:M
        % make the network request to send to the server
        request = struct();
        request.msg = 'enqueue_job';
        request.job.hash = config_hashes{a};
        request.job.config = configs{a};
        request.job.run_name = run_names{a};

        try
            response = jobmgr.netsrv.make_request(request);
        catch E
            if strcmp(E.identifier, 'MATLAB:client_communicate:need_init')
                fprintf('Job Manager: Assuming job server is running on localhost.\nIf this is incorrect, pass the server hostname to jobmgr.netsrv.start_client\n');
                % add remote server
                jobmgr.netsrv.start_client(server{1}, jobmgr.server.tcp_port);
                response = jobmgr.netsrv.make_request(request);
            else
                rethrow(E);
            end
        end
        
        % unpack the computed result
        if strcmp(response.status, 'Error')
            if isfield(response, 'message')
                message = sprintf('\n\tMessage from server: %s', response.message);
            else
                message = '';
            end
            error('Failed to submit job to server.\n\tJob name: %s\n\tHash: %s%s', run_names{a}, config_hashes{a}, message);
        end
        
        if ~isempty(response.result)
            r{a} = response.result;
            jobmgr.store(configs{a}.solver, config_hashes{a}, r{a});
        end
    end
end
