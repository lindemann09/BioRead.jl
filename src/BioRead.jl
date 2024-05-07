module BioRead

using PyCall
using Dates

try
    pyimport("bioread")
catch
    throw(DomainError("Can't find the python libarary 'bioread'. "))
end

export BioPacChannel,
    BioPacDataFile,
    read,
    get_channel,
    Matrix,
    time_index,
    trigger,
    names,
    units,
    # extension dataframes
    trigger_dataframe

include("utils.jl")
include("channel.jl")
include("data_file.jl")

## extensions
trigger_dataframe(::Any) = throw(ArgumentError("You have not loaded DataFrames?"))

if !isdefined(Base, :get_extension)
    include("../ext/DataFramesExt.jl")
end


# Write your package code here.
end
