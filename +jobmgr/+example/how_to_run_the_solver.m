%% How to run the solver

%% Simple example using the default settings
config = struct();
config.solver = @jobmgr.example.solver;
r = jobmgr.run(config);
disp(r);

%% Run two configs in parallel with parfor
config = struct();
config.solver = @jobmgr.example.solver;

c1 = config;
c1.input = [10 11 12];

c2 = config;
c2.input = [100 200];
c2.mode = 'triple';

configs = {c1, c2};

run_opts = struct();
run_opts.run_names = {'c1', 'c2'};

r = jobmgr.run(configs, run_opts);
disp(r{1});
disp(r{2});

%% Run two configs on the job server
% You must start the job server and workers separately. See the README
% file.
config = struct();
config.solver = @jobmgr.example.solver;

c1 = config;
Test = fopen('input_T1.nii');
c1.input = Test;

c2 = config;
c2.input = 1:11;

c2.mode = 'triple';

c4 = config;
c4.input = 1:15;

configs = {c1, c2, c4};

run_opts = struct();
run_opts.execution_method = 'job_server';
run_opts.run_names = {'c1', 'c2', 'c4'};

r = jobmgr.run(configs, run_opts);
disp(r{1});
disp(r{2});
disp(r{3});

%% Submit a job with qsub
config = struct();
config.solver = @jobmgr.example.solver;
config.input = 1:30;

run_opts = struct();
run_opts.execution_method = 'qsub';

r = jobmgr.run({config}, run_opts);
disp(r);