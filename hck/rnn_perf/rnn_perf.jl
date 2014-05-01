#!/usr/bin/env julia

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

function forward(W, x, a)
    # a = tanh(W * x)
    for row in 1:size(W, 1)
        a[row] = 0
        for col in 1:size(W, 2)
            @inbounds a[row] += W[row, col] * x[col]
        end
        a[row] = tanh(a[row])
    end
end

function tanh_prime(x)
    return 1 - x .^ 2
end

function backward(x, a, d, b)
    # b = return (tanh_prime(a) .* d) * x'
    for row in 1:size(b, 1)
        @inbounds ad = (1.0 - a[row] ^ 2) * d[row]
        for col in 1:size(b, 2)
            @inbounds b[row, col] = ad * x[col]
        end
    end
end

W = fill!(Array(Float64, OUT, IN), INIT_VAL)
x = fill!(Array(Float64, IN), INIT_VAL)
d = fill!(Array(Float64, OUT), INIT_VAL)

a = Array(Float64, OUT)
b = Array(Float64, OUT, IN)

tic()
for _ in 1:NUM_ITS
    forward(W, x, a)
    backward(x, a, d, b)

    # Avoids scoping issues and has a minimal, if any, effect on performance.
    if DEBUG
        print(a')
        print(b)
    end
end
toc = toq()

println(toc)
