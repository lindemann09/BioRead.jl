
struct BiopacChannel{T <: AbstractFloat}
    data::Vector{T}
    frequency_divider::Int64
    raw_scale_factor::Float64
    raw_offset::Float64
    name::String
    units::String
    samples_per_second::Float64
    point_count:: Int64 # n_samples
end;

function BiopacChannel(x::PyCall.PyObject)
    return BiopacChannel(x.data,
            x.frequency_divider,
            Float64(x.raw_scale_factor),
            Float64(x.raw_offset),
            x.name,
            x.units,
            Float64(x.samples_per_second),
            x.point_count)
end

Base.propertynames(::BiopacChannel) = (fieldnames(BiopacChannel)..., :raw_data, :n_samples, :upsampled_data)
function Base.getproperty(x::BiopacChannel, s::Symbol)
	if s === :raw_data
        # The channel's data, scaled by the raw_scale_factor and offset.
		return (x.data .- x.raw_offset) ./ x.raw_scale_factor
	elseif s === :n_samples
		return x.point_count
	elseif s === :upsampled_data
        # The channel's data, sampled at the native frequency of the file.
        # All channels will have the same number of points using this method
		return upsample(x.data, x.frequency_divider)
	else
		return getfield(x, s)
	end
end

function Base.show(io::IO, mime::MIME"text/plain", x::BiopacChannel)
	println(io, "BiopacChannel $(x.name): $(x.point_count) samples, $(x.samples_per_second) samples/sec")
end;

function time_index(ch::BiopacChannel)
    return time_index(ch.point_count, ch.samples_per_second;
                frequency_divider= ch.frequency_divider)
end

## channel header
struct BiopacChannelHeader
    offset::Int64
    file_revision::Int64
    encoding::String
    data::Dict
end;

function BiopacChannelHeader(x::PyCall.PyObject)
    return BiopacChannelHeader(x.offset,
            x.file_revision,
            x.encoding,
            x.data)
end
