function time_index(n_samples::Int,  samples_per_second::Real;
                frequency_divider::Int = 1)
    "time index in seconds"
    start = 1 / samples_per_second
    stop = n_samples / samples_per_second
    if frequency_divider > 1
        step = start * frequency_divider
    else
        step = start
    end
    return collect(range(; start, stop, step))
end

function upsample(data::Vector{<:Real}, frequency_divider::Int)
    "upsampling data using Nearest-neighbor sampling"
    total_samples = length(data) * frequency_divider
    ids = ceil.(Int, range(1, total_samples)/frequency_divider)
    return data[ids]
end
