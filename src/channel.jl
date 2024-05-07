struct BioPacChannel{T <: AbstractFloat}
    data::Vector{T}
    frequency_divider::Int64
    raw_scale_factor::T
    raw_offset::T
    name::String
    units::String
    samples_per_second::Float64
    point_count:: Int64 # n_samples
end;

function BioPacChannel(x::PyCall.PyObject)
    return BioPacChannel(x.data,
            x.frequency_divider,
            x.raw_scale_factor,
            x.raw_offset,
            x.name,
            x.units,
            x.samples_per_second,
            x.point_count)
end

Base.propertynames(::BioPacChannel) = (fieldnames(BioPacChannel)..., :raw_data, :time_index, :n_samples, :upsampled_data)
function Base.getproperty(x::BioPacChannel, s::Symbol)
	if s === :raw_data
        # The channel's data, scaled by the raw_scale_factor and offset.
		return (x.data .- x.raw_offset) ./ x.raw_scale_factor
	elseif s === :time_index
		return time_index(x.point_count, x.samples_per_second;
                    frequency_divider= x.frequency_divider)
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

function Base.show(io::IO, mime::MIME"text/plain", x::BioPacChannel)
	println(io, "BioPacChannel $(x.name): $(x.point_count) samples, $(x.samples_per_second) samples/sec")
end;

## channel header

struct BioPacChannelHeader
    offset::Int64
    file_revision::Int64
    encoding::String
    data::Dict
end;

function BioPacChannelHeader(x::PyCall.PyObject)
    return BioPacChannelHeader(x.offset,
            x.file_revision,
            x.encoding,
            x.data)
end
