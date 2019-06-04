# Defining all valve types

# WNTR valve = PRValve
struct PressureReducingValve<:Valve
    number::Int64 #for incidence matrix
    name::String
    connectionpoints::NamedTuple{(:from, :to), Tuple{Junction, Junction}} # for topology of network and knowing what connects to what
    status::String #open/closed/active
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
    internal:: WaterSystemInternal
end
function PressureReducingValve(number, name, connectionspoints, status, diameter, pressure_drop)
    PressureReducingValve(number, name, connectionpoints, status, diameter, pressure_drop, WaterSystemInternal())
end 

PressureReducingValve(;
                    number = 1,
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = PressureReducingValve(number, name, connectionpoints, status, diameter, pressure_drop)

struct GateValve <: Valve
    status::Int64
    internal:: WaterSystemInternal
end
function GateValve(status)
    GateValve(status, WaterSystemInternal())
end 
GateValve(;
        status = 0
        ) = GateValve(status, WaterSystemInternal())

# Ariel addidng other valves below
# MISSING?! -- minor_loss, _user_status AND _initial_status, initial_setting, head loss, pressure difference instead of drop?!?!?!?

# WNTR valve = PSValve
struct PressureSustainingValve<:Valve
    number::Int64
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
    internal:: WaterSystemInternal
end
function PressureSustainingValve(number, name, connectionpoints, status, diameter, pressure_drop)
    PressureSustainingValve(number, name, connectionpoints, status, diameter, pressure_drop, WaterSystemInternal())
end 
PressureSustainingValve(;
                    number = 1,
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = PressureSustainingValve(number, name, connectionpoints, status, diameter, pressure_drop)

# WNTR valve = PBValve
struct PressureBreakerValve<:Valve
    number::Int64
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
    internal:: WaterSystemInternal
end
function PressureBreakerValve(number,name,connectionpoints, status, diameter, pressure_drop)
    PressureBreakerValve(number, name, connectionpoints, status, diameter, pressure_drop, WaterSystemInternal())
end 
PressureBreakerValve(;
                    number = 1,
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = PressureBreakerValve(number, name, connectionpoints, status, diameter, pressure_drop) 

# WNTR valve = FCValve
struct FlowControlValve<:Valve
    number::Int64
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
    internal:: WaterSystemInternal
end

function FlowControlValve(number, name, connectionpoints, status, diameter, pressure_drop)
    FlowControlValve(number, name, connectionpoints, status, diameter, pressure_drop, WaterSystemInternal())
end 
FlowControlValve(;
                    number = 1,
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = FlowControlValve(number, name, connectionpoints, status, diameter, pressure_drop)

# WNTR valve = TCValve
struct ThrottleControlValve<:Valve
    number::Int64
    name::String
    connectionpoints::NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
    internal:: WaterSystemInternal
end
function ThrottleControlValve(number,name, connectionpoints, status, diameter, pressure_drop)
    ThrottleControlValve(number, name, connectionpoints, status, diameter, pressure_drop, WaterSystemInternal())
end 
ThrottleControlValve(;
                    number = 1,
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = ThrottleControlValve(number, name, connectionpoints, status, diameter, pressure_drop)

# WNTR valve = GPValve
struct GeneralPurposeValve<:Valve
    number::Int64
    name::String
    connectionpoints::NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
    internal:: WaterSystemInternal
end
function GeneralPurposeValve(number, name, connectionpoints, status, diameter, pressure_drop)
    GeneralPurposeValve(number, name, connectionpoints, status, diameter, pressure_drop, WaterSystemInternal())
end 
GeneralPurposeValve(;
                    number = 1,
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = GeneralPurposeValve(number, name, connectionpoints, status, diameter, pressure_drop)
