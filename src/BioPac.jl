module BioPac

using PyCall
using DataFrames
using Dates

try
    pyimport("bioread")
catch
    throw(DomainError("Can't find the python libarary 'bioread'. "))
end

export BiopacChannel,
    BiopacData,
    read_acq_file,
    get_channel,
    Matrix,
    time_index,
    trigger_values,
    trigger,
    names,
    units,
    DataFrame

struct BiopacChannel{T <: AbstractFloat}
	data::Vector{T}
    name::AbstractString
    units::AbstractString
    frequency_divider::Int64
    point_count:: Int64
end;

struct BiopacData{T <: AbstractFloat}
	channels::Vector{BiopacChannel{T}}
    samples_per_second::Float64
    earliest_marker_created_at:: DateTime
end;

function read_acq_file(flname::String)
    @time bioread = pyimport("bioread")
    acq = bioread.read_file(flname)
    dat = Vector{BiopacChannel{Float64}}()
    bit = 0
    for x in acq.channels
        if x.name == "Digital input"
            bit += 1
            name =  "DI" * string(bit)
        else
            name = x.name
        end
        push!(dat, BiopacChannel(x.data, name, x.units,
                x.frequency_divider, x.point_count) )
    end
    datetime = DateTime(acq.earliest_marker_created_at)
    return BiopacData(dat, acq.samples_per_second, datetime)
end

function get_channel(biodat::BiopacData, name::Union{AbstractString, Symbol})
    for x in biodat.channels
        if x.name == String(name)
            return x
        end
    end
end

function Base.Matrix(biodat::BiopacData)
    dat = [x.data for x in biodat.channels]
    return reduce(hcat, dat)
end

function trigger_values(biodat::BiopacData)
    rtn = nothing
    for x in biodat.channels
        if startswith(x.name, "DI")
            place = parse(Int8, x.name[length(x.name)]) - 1 # place, 0..7
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

Base.names(biodat::BiopacData) =  [x.name for x in biodat.channels]
units(biodat::BiopacData) =  [x.units for x in biodat.channels]

function trigger(biodat::BiopacData)
    rtn = DataFrame(trigger = Vector{Int}(),
                    idx = Vector{Int}(),
                    len = Vector{Int}())
    last = 0
    idx = 0
    len = 0
    for (i, x) in enumerate(trigger_values(biodat))
        if x != last
            if last != 0
                push!(rtn, (last, idx, len))
            end
            last = x
            idx = i
            len = 1
        else
            len += 1
        end
    end
    return(rtn)
end

function time_index(bio_dat::BiopacData)
    "time index in seconds"
    total_samples = maximum([ch.frequency_divider * ch.point_count
                                        for ch in bio_dat.channels])
    total_seconds = total_samples / bio_dat.samples_per_second
    return Vector(range(start=0, stop=total_seconds, length=total_samples))
end

function DataFrames.DataFrame(biodat::BiopacData;
                    digital_input::Bool=true,
                    time::Bool=false)
    mtx = Matrix(biodat)
    col_names =  names(biodat)
    if time
        mtx = hcat(time_index(biodat), mtx)
        col_names = vcat(["time"], col_names)
    end

    rtn = DataFrame(mtx, col_names)
    rtn.trigger = trigger_values(biodat)
    if digital_input
        return rtn
    else
        sel_name = [x for x in names(rtn) if !startswith(x, "DI")]
        return select(rtn, sel_name...)
    end
end


# Write your package code here.
end
