#!/usr/bin/env julia

# TODO: Look at rnn_perf.c for inspiration?

const DEBUG = false
if !DEBUG
    const IN = 32
    const OUT = 64
    const NUM_ITS = 10 ^ 6
else
    const IN = 4
    const OUT = 2
    const NUM_ITS = 1
end
const INIT_VAL = 0.4711

function forward(W, x)
    return tanh(W * x)
end

function tanh_prime(x)
    return 1 - x .^ 2
end

function backward(x, a, m)
    return (tanh_prime(a) .* m) * x'
end

W = fill!(Array(Float64, OUT, IN), INIT_VAL)
x = fill!(Array(Float64, IN), INIT_VAL)
m = fill!(Array(Float64, OUT), INIT_VAL)

tic()
for _ in 1:NUM_ITS
    a = forward(W, x)
    b = backward(x, a, m)

    # Avoids scoping issues and has a minimal effect on performance.
    if DEBUG
        print(a')
        print(b)
    end
end
toc = toq()

print(toc)
