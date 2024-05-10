function time_index(n_samples::Int,
	samples_per_second::Real;
	frequency_divider::Int = 1,
	start_time::Union{Nothing, Real} = nothing)
	"time index in seconds"
	step = 1 / samples_per_second
	if start_time === nothing
		start = step
		stop = n_samples / samples_per_second
	else
		start = start_time
		stop = ((n_samples - 1) / samples_per_second) + start_time
	end
	if frequency_divider > 1
		step = step * frequency_divider
	end
	return range(; start, stop, step)
end

function upsample(data::Vector{<:Real}, frequency_divider::Int)
	"upsampling data using Nearest-neighbor sampling"
	if frequency_divider == 1
		return data
	else
		total_samples = length(data) * frequency_divider
		ids = ceil.(Int, range(1, total_samples) / frequency_divider)
		return data[ids]
	end
end
