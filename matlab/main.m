clear;
close all;

if isunix:
    os = 'linux';
else if ispc:
    os = 'windows';

names = ["0_GT01R.mat","1_TSC_OPF_1047.mat", ...
    "2_ns3Da.mat","4_ifiss_mat.mat", ...
    "5_bundle_adj.mat","6_G3_circuit.mat"];
datadir = fullfile("..", "data", "matlab");

data = [];
for i = 1:length(names)
    filename = names(i);
    m = load(fullfile(datadir, filename));
    m = m.Problem;

    A = sparse(m.A);
    clear("m");

    [N, err, t] = solve(A);
    data = [data; [N, err, t]];
    fprintf("%d, %e, %f, \n", N, err, t);
end

output_path = fullfile("output", strcat(os, ".csv"));
T = array2table(data);
T.Properties.VariableNames(1:3) = ["N","Error", "Time"];
writetable(T, output_path);

function [N, err, time] = solve(A)
    N = size(A, 1);
    e = ones(N, 1);
    b = A * e;
    
    tic;
    x = A \ b;
    time = toc;
    
    err = norm(e - x) / norm(e);
end
