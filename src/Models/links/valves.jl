struct PressureReducingValve<:Valve
    number::Int64
    name::String
    connectionpoints::@NT(from::Junction, to::Junction)
    status::String
    diameter::Union{Nothing,Float64} #m
    pressure_drop::Union{Nothing,Float64} #m
end

PressureReducingValve(;
                    number = 1,
                    name="init",
                    connectionpoints= @NT(from::Junction(), to::Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = PressureReducingValve(number, name, connectionpoints, status, diameter, pressure_drop)
