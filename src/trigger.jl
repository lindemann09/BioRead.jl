struct Trigger
    bytes::Vector{Int64}
    time_index::AbstractRange
end

function Trigger(biodat::BiopacData; zero_trigger::Bool=false)
    #bytes
    tr_bytes = nothing
    place = -1
    for x in biodat.channels
        if startswith(x.name, "Digital ")
            place += 1
            bits = (x.data .> 0) .<< place
            if isnothing(tr_bytes)
                tr_bytes = bits
            else
                tr_bytes = tr_bytes .| bits
            end
        end
    end
    return Trigger(tr_bytes, time_index(biodat))
end

function trigger_ranges(x::Trigger; zero_trigger::Bool=false)
    trigger = Int64[]
    ranges = UnitRange{Int64}[]
    last_tr = -1
    idx = 0
    for (i, x) in enumerate(x.bytes)
        if x != last_tr
            if last_tr > 0 || (zero_trigger && last_tr != -1)
                push!(trigger, last_tr)
                push!(ranges, range(idx, i-1))
            end
            last_tr = x
            idx = i
        end
    end
    if last_tr != 0 || zero_trigger
        push!(trigger, last_tr)
        push!(ranges, range(idx, length(bytes)))
    end
    return (; trigger, ranges)
end
