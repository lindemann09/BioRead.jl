module BioRead

using PyCall
using Dates

try
    pyimport("bioread")
catch
    throw(DomainError("Can't find the python libarary 'bioread'. "))
end

export BiopacChannel,
    BiopacDataFile,
    Trigger,
    read,
    get_channel,
    Matrix,
    trigger_bytes,
    time_index

include("utils.jl")
include("channel.jl")
include("data_file.jl")
include("trigger.jl")


if !isdefined(Base, :get_extension)
    include("../ext/DataFramesExt.jl")
end


# Write your package code here.
end
