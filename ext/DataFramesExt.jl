module DataFramesExt

using DataFrames
using BioRead

export DataFrame,
    trigger_dataframe;


function DataFrames.DataFrame(biodat::BiopacDataFile;
                    digital_input::Bool=true,
                    time_index::Bool=false)
    mtx = Matrix(biodat)
    col_names =  String[]
    cnt = 0
    for x in biodat.channel_names
        if x == BioRead.digital_input_str
            cnt += 1
            x = x * string(cnt)
        end
        push!(col_names, replace(x, " "=>"_"))
    end
    if time_index
        mtx = hcat(BioRead.time_index(biodat), mtx)
        col_names = vcat(["time"], col_names)
    end

    rtn = DataFrame(mtx, col_names)
    rtn.trigger  = trigger_bytes(biodat)
    if digital_input
        return rtn
    else
        # remove digital_inputs
        di = replace(BioRead.digital_input_str, " "=>"_")
        sel_name = [x for x in names(rtn) if !startswith(x, di)]
        return select(rtn, sel_name...)
    end
end

function DataFrames.DataFrame(trigger::Trigger)
    return DataFrame(trigger = trigger.trigger,
                    start = [x.start for x in trigger.ranges],
                    len = [length(x) for x in trigger.ranges])
end


end; ##