const digital_input_str = "Digital input"

struct Trigger
    signal::Vector{Int64}
    trigger::Vector{Int64}
    ranges::Vector{UnitRange{Int64}}
end

function Trigger(biodat::BiopacDataFile)
    signal = trigger_bytes(biodat)
    trigger = Int64[]
    ranges = UnitRange{Int64}[]

    last_tr = 0
    idx = 0
    for (i, x) in enumerate(signal)
        if x != last_tr
            if last_tr != 0
                push!(trigger, last_tr)
                push!(ranges, range(idx, i-1))
            end
            last_tr = x
            idx = i
        end
    end
    return Trigger(signal, trigger, ranges)
end


function trigger_bytes(biodat::BiopacDataFile)
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

