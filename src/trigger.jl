struct Trigger
    signal::Vector{Int64}
    trigger::Vector{Int64}
    ranges::Vector{UnitRange{Int64}}
    time_index::AbstractRange
end

function Trigger(biodat::BiopacData; zero_trigger::Bool=false)
    signal = trigger_bytes(biodat)
    trigger = Int64[]
    ranges = UnitRange{Int64}[]
    last_tr = -1
    idx = 0
    for (i, x) in enumerate(signal)
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
        push!(ranges, range(idx, length(signal)))
    end
    return Trigger(signal, trigger, ranges, time_index(biodat))
end


function trigger_bytes(biodat::BiopacData)
    "extracts trigger from digital input"
    rtn = nothing
    place = -1
    for x in biodat.channels
        if startswith(x.name, "Digital ")
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

