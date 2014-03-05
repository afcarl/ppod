DEBUG = false;
if ~DEBUG
    IN = 32;
    OUT = 64;
    NUM_ITS = 10 ^ 6;
else
    IN = 4;
    OUT = 2;
    NUM_ITS = 1;
end
INIT_VAL = 0.4711;

% Note: Anonymous functions are even slower (2x) than ordinary functions.
forward = @(W, x) tanh(W * x);

tanhPrime = @(x) 1 - x .^ 2;

backward = @(x, a, m) (tanhPrime(a) .* m) * x';

W = repmat(INIT_VAL, OUT, IN);
x = repmat(INIT_VAL, IN, 1);
m = repmat(INIT_VAL, OUT, 1);

tic
for i = 1:NUM_ITS
    % In-line all functions since the function overhead is dreadful.
    %a = forward(W, x);
    a = tanh(W * x);

    %b = backward(x, a, m);
    b = ((1 - a .^ 2) .* m) * x';
end
duration = toc;

if DEBUG
    for e = a
        fprintf(1, '%f ', e)
    end
    fprintf(1, '\n')
    for r = size(b, 1)
        for e = b(r, :)
            fprintf(1, '%f ', e)
        end
        fprintf(1, '\n')
    end
end

fprintf(1, 'Elapsed time is %f seconds.', duration)

quit
