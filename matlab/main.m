clear;
close all;

filename = "0_GT01R.mat";
datadir = fullfile("..", "data", "matlab");

m = load(fullfile(datadir, filename));
m = m.Problem;

A = sparse(m.A);
clear("m");

[N, err, t] = solve(A);
fprintf("%d, %e, %f, \n", N, err, t);

function [N, err, time] = solve(A)
    N = size(A, 1);
    e = ones(N, 1);
    b = A * e;
    
    tic;
    x = A \ b;
    time = toc;
    
    err = norm(e - x) / norm(e);
end
