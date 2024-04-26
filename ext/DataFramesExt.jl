module DataFramesExt

using DataFrames
using BioPac

export DataFrame,
    trigger_dataframe;


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
    rtn.trigger = trigger(biodat)
    if digital_input
        return rtn
    else
        sel_name = [x for x in names(rtn) if !startswith(x, "DI")]
        return select(rtn, sel_name...)
    end
end

function BioPac.trigger_dataframe(biodat::BiopacData)
    rtn = DataFrame(trigger = Vector{Int}(),
                    idx = Vector{Int}(),
                    len = Vector{Int}())
    last = 0
    idx = 0
    len = 0
    for (i, x) in enumerate(trigger(biodat))
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


end; ##