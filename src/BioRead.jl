module BioRead

using PyCall
using Dates
using JLD2, CodecZlib

export BiopacData,
    BiopacChannel,
    Trigger,
    read,
    read_acq,
    get_channel,
    Matrix,
    trigger_ranges,
    time_index,
    convert_acq_to_jld2,
    convert_acq_data_folder

include("utils.jl")
include("channel.jl")
include("data_file.jl")
include("trigger.jl")


if !isdefined(Base, :get_extension)
    include("../ext/DataFramesExt.jl")
end

end
