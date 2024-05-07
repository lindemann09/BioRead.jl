struct BioPacDataFile{T <: AbstractFloat}
    #graph_header
    channel_headers::Vector{BioPacChannelHeader}
    #foreign_header
    #channel_dtype_headers
    samples_per_second::Float64
    name::Union{Nothing, String}
    #marker_header
    #marker_item_headers
    #event_markers
    #journal_header
    #journal
	channels::Vector{BioPacChannel{T}}
    earliest_marker_created_at:: DateTime
    acq_file::String # addional variable
end;

Base.propertynames(::BioPacDataFile) = (fieldnames(BioPacDataFile)...,
                        :time_index, :channel_names, :channel_units)
function Base.getproperty(x::BioPacDataFile, s::Symbol)
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

function Base.read(::Type{BioPacDataFile}, acq_file::String)
    bioread = pyimport("bioread")
    acq = bioread.read(acq_file)
    channels = Vector{BioPacChannel{Float64}}()
    headers = Vector{BioPacChannelHeader}()
    for x in acq.channels
        push!(channels, BioPacChannel(x))
    end
    for x in acq.channel_headers
        push!(headers, BioPacChannelHeader(x))
    end

    dt = DateTime(acq.earliest_marker_created_at)
    return BioPacDataFile(headers, acq.samples_per_second, acq.name, channels,
                dt, acq_file)
end



function Base.show(io::IO, mime::MIME"text/plain", x::BioPacDataFile)
	println(io, "BioPacDataFile")
    for (cnt, ch) in enumerate(x.channels)
        println(io, "  channel $cnt: $(ch.name): $(ch.point_count) samples")
    end
end;


function get_channel(biodat::BioPacDataFile, name::Union{AbstractString, Symbol})
    for x in biodat.channels
        if x.name == String(name)
            return x
        end
    end
end

function Base.Matrix(biodat::BioPacDataFile)
    dat = [x.upsampled_data for x in biodat.channels]
    return reduce(hcat, dat)
end


const digital_input_str = "Digital input"

function trigger(biodat::BioPacDataFile)
    "extracts trigger from digital input"
    rtn = nothing
    place = 0
    for x in biodat.channels
        if x.name == digital_input_str
            place += 1
            bits = (x.data .> 0) .<< place
            if isnothing(rtn)
                rtn = bits
            else
                rtn = rtn .| bits
            end
        end
    end
    return rtn
end

