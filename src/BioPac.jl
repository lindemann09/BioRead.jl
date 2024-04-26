module BioPac

using PyCall
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
    trigger,
    names,
    units,
    # extension dataframes
    trigger_dataframe

include("lib.jl")

## extensions
trigger_dataframe(::Any) = throw(ArgumentError("You have not loaded DataFrames?"))

if !isdefined(Base, :get_extension)
    include("../ext/DataFramesExt.jl")
end


# Write your package code here.
end
