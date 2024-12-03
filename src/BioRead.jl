module BioRead

using PyCall
using Dates

export BiopacData,
    BiopacChannel,
    Trigger,
    read,
    read_acq,
    get_channel,
    Matrix,
    trigger_ranges,
    time_index

include("utils.jl")
include("channel.jl")
include("data_file.jl")
include("trigger.jl")


if !isdefined(Base, :get_extension)
    include("../ext/DataFramesExt.jl")
end

end
