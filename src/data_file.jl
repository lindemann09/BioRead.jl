struct BioPacDataFile{T <: AbstractFloat}
	channels::Vector{BioPacChannel{T}}
    samples_per_second::Float64
    earliest_marker_created_at:: DateTime
end;

Base.names(biodat::BioPacDataFile) =  [x.name for x in biodat.channels]
units(biodat::BioPacDataFile) =  [x.units for x in biodat.channels]


function Base.show(io::IO, mime::MIME"text/plain", x::BioPacDataFile)
	println(io, "BioPacDataFile")
    for (cnt, ch) in enumerate(x.channels)
        println(io, "  channel $cnt: $(ch.name): $(ch.point_count) samples")
    end
end;

function Base.read(::Type{BioPacDataFile}, flname::String)
    bioread = pyimport("bioread")
    acq = bioread.read(flname)
    dat = Vector{BioPacChannel{Float64}}()
    #bit = 0
    for x in acq.channels
        #if x.name == "Digital input"
        #    bit += 1
        #    name =  "DI" * string(bit)
        #else
        #    name = x.name
        #end
        ch = BioPacChannel(x)
        push!(dat, ch)
    end
    dt = DateTime(acq.earliest_marker_created_at)
    return BioPacDataFile(dat, acq.samples_per_second, dt)
end

function get_channel(biodat::BioPacDataFile, name::Union{AbstractString, Symbol})
    for x in biodat.channels
        if x.name == String(name)
            return x
        end
    end
end

function Base.Matrix(biodat::BioPacDataFile)
    dat = [x.data for x in biodat.channels]
    return reduce(hcat, dat)
end

function trigger(biodat::BioPacDataFile)
    "extracts trigger from digital input"
    rtn = nothing
    place = 0
    for x in biodat.channels
        if x.name == "Digital input"
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

#function time_index(bio_dat::BioPacDataFile)
#    "time index in seconds"
#    total_samples = maximum([ch.frequency_divider * ch.point_count
#                                        for ch in bio_dat.channels])
#    return time_index(total_samples, bio_dat.samples_per_second)
#end

