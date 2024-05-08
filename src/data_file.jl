struct BiopacDataFile{T <: AbstractFloat}
    #graph_header
    channel_headers::Vector{BiopacChannelHeader}
    #foreign_header
    #channel_dtype_headers
    samples_per_second::Float64
    name::Union{Nothing, String}
    #marker_header
    #marker_item_headers
    #event_markers
    #journal_header
    #journal
	channels::Vector{BiopacChannel{T}}
    earliest_marker_created_at:: DateTime
    acq_file::String # addional variable
end;

Base.propertynames(::BiopacDataFile) = (fieldnames(BiopacDataFile)...,
                        :time_index, :channel_names, :channel_units)
function Base.getproperty(x::BiopacDataFile, s::Symbol)
	if s === :time_index
        total_samples = maximum([ch.frequency_divider * ch.point_count
                                    for ch in bio_dat.channels])
        return time_index(total_samples, x.samples_per_second)
	elseif s === :channel_names
        return [c.name for c in x.channels]
	elseif s === :channel_units
        return [c.units for c in x.channels]
	else
        return getfield(x, s)
	end
end

function Base.read(::Type{BiopacDataFile}, acq_file::AbstractString)
    bioread = pyimport("bioread")
    acq = bioread.read(acq_file)
    channels = Vector{BiopacChannel{Float64}}()
    headers = Vector{BiopacChannelHeader}()
    for x in acq.channels
        push!(channels, BiopacChannel(x))
    end
    for x in acq.channel_headers
        push!(headers, BiopacChannelHeader(x))
    end

    dt = DateTime(acq.earliest_marker_created_at)
    return BiopacDataFile(headers, acq.samples_per_second, acq.name, channels,
                dt, acq_file)
end

BiopacDataFile(acq_file::AbstractString) = read(BiopacDataFile, acq_file)

function Base.show(io::IO, mime::MIME"text/plain", x::BiopacDataFile)
	println(io, "BiopacDataFile")
    for (cnt, ch) in enumerate(x.channels)
        println(io, "  channel $cnt: $(ch.name): $(ch.point_count) samples")
    end
end;


function get_channel(biodat::BiopacDataFile, name::Union{AbstractString, Symbol})
    for x in biodat.channels
        if x.name == String(name)
            return x
        end
    end
end

function Base.Matrix(biodat::BiopacDataFile)
    dat = [x.upsampled_data for x in biodat.channels]
    return reduce(hcat, dat)
end


