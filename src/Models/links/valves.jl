# Defining all valve types

# WNTR valve = PRValve
struct PressureReducingValve<:Valve
    name::String
    connectionpoints::NamedTuple{(:from, :to), Tuple{Junction, Junction}} # for topology of network and knowing what connects to what
    status::String #open/closed/active
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
end

PressureReducingValve(;
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = PressureReducingValve(name, connectionpoints, status, diameter, pressure_drop)

struct GateValve <: Valve
    status::Int64
end

GateValve(;
        status = 0
        ) = GateValve(status)

# Ariel addidng other valves below
# MISSING?! -- minor_loss, _user_status AND _initial_status, initial_setting, head loss, pressure difference instead of drop?!?!?!?

# WNTR valve = PSValve
struct PressureSustainingValve<:Valve
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
end

PressureSustainingValve(;
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = PressureSustainingValve(name, connectionpoints, status, diameter, pressure_drop)

# WNTR valve = PBValve
struct PressureBreakerValve<:Valve
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
end

PressureBreakerValve(;
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = PressureBreakerValve(name, connectionpoints, status, diameter, pressure_drop)

# WNTR valve = FCValve
struct FlowControlValve<:Valve
    name::String
    connectionpoints:: NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
end

FlowControlValve(;
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = FlowControlValve(name, connectionpoints, status, diameter, pressure_drop)

# WNTR valve = TCValve
struct ThrottleControlValve<:Valve
    name::String
    connectionpoints::NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
end

ThrottleControlValve(;
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = ThrottleControlValve(name, connectionpoints, status, diameter, pressure_drop)

# WNTR valve = GPValve
struct GeneralPurposeValve<:Valve
    name::String
    connectionpoints::NamedTuple{(:from, :to), Tuple{Junction, Junction}}
    status::String
    diameter::Union{Nothing,Float64}
    pressure_drop::Union{Nothing,Float64}
end

GeneralPurposeValve(;
                    name="init",
                    connectionpoints= (from = Junction(), to = Junction()),
                    status="Closed",
                    diameter=1.0,
                    pressure_drop=nothing
                    ) = GeneralPurposeValve(name, connectionpoints, status, diameter, pressure_drop)
