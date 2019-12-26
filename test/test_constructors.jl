

@testset "Topology Constructors" begin
    t_junct = WSY.Junction(nothing)
    @test t_junct isa WSY.WaterSystemType
    @test t_junct isa WSY.Topology
    junction = WSY.Junction("test", 0.0, 0.0, 0.0, (lat=0.0, lon=0.0)) 

    t_arc = WSY.Arc(nothing) 
    @test t_arc isa WSY.WaterSystemType
    @test t_arc isa WSY.Topology    
    arc = WSY.Arc("test", WSY.Junction(nothing), WSY.Junction(nothing))
 end

@testset "Injection constructors" begin
    t_res = WSY.Reservoir(nothing)
    @test t_res isa WSY.Injection
    t_tank = WSY.CylindricalTank(nothing)
    @test t_tank isa WSY.Injection
    @test t_tank isa WSY.Tank
    t_demand = WSY.StaticDemand(nothing)
    @test t_demand isa WSY.Injection
    @test t_demand isa WSY.WaterDemand
end

@testset "Technical parameters constructors" begin
    t_pattern = WSY.Pattern(nothing)
    @test t_pattern isa WSY.TechnicalParams
    t_curve = WSY.Curve(nothing)
    @test t_curve isa WSY.TechnicalParams
    #TODO: checks on pump parameter types
end

# intermediate testing of parsing an epanet file and constructing subtypes of WaterSystems
@testset "Consctructors from epanet data" begin
    # what comparative tests would be useful here? mainly just making sure no errors are
    # thrown JJS 12/20/19
    data = WSY.make_dict(epanet_test_path)
    # test creation of junction structs
    junctions = WSY.junction_to_struct(data["Junction"])
    @test junctions isa Array{WaterSystems.Junction,1}
    j_dict = Dict{String, WSY.Junction}(junction.name => junction for junction in junctions)
    # test creation of arc structs
    arcs = WSY.link_to_struct(data["Link"], j_dict)
    @test arcs isa Array{WaterSystems.Arc,1}
    # test creation of reservoir structs
    reservoirs = WSY.res_to_struct(data["Reservoir"], j_dict)
    @test reservoirs isa Array{WaterSystems.Reservoir,1}
    # test creation of tank structs
    tanks = WSY.tank_to_struct(data["Tank"], j_dict)
    @test tanks isa Array{WaterSystems.Tank,1}
    # test creation of demand structs (does not populate the forecast arrays here)
    demands = WSY.demand_to_struct(data["Demand"], j_dict)
    @test demands isa Array{WaterSystems.WaterDemand,1}
    # test creation of pattern and curve structs
    patterns = WSY.pattern_to_struct(data["Pattern"])
    @test patterns isa Array{WaterSystems.Pattern,1}
    curves = WSY.curve_to_struct(data["Curve"])
    @test curves isa Array{WaterSystems.Curve,1}
    
    # testing constructors for technical parameters and links TBD
end

# @testset "Branch Constructors" begin
#     tLine = Line(nothing)
#     @test tLine isa PowerSystems.Component
#     tMonitoredLine = MonitoredLine(nothing)
#     @test tMonitoredLine isa PowerSystems.Component
#     tHVDCLine = HVDCLine(nothing)
#     @test tHVDCLine isa PowerSystems.Component
#     tVSCDCLine = VSCDCLine(nothing)
#     @test tVSCDCLine isa PowerSystems.Component
#     tTransformer2W = Transformer2W(nothing)
#     @test tTransformer2W isa PowerSystems.Component
#     tTapTransformer = TapTransformer(nothing)
#     @test tTapTransformer isa PowerSystems.Component
#     tPhaseShiftingTransformer = PhaseShiftingTransformer(nothing)
#     @test tPhaseShiftingTransformer isa PowerSystems.Component
# end

# @testset "Forecast Constructors" begin
#     tg = RenewableFix(nothing)
#     forecast_data = PowerSystems.TimeSeries.TimeArray([DateTime("01-01-01"), DateTime("01-01-01")+Hour(1)], [1.0, 1.0])
#     #Deterministic Tests
#     tDeterministicForecast = PSY.Deterministic("scalingfactor", Hour(1),DateTime("01-01-01"),24)
#     @test tDeterministicForecast isa PowerSystems.Forecast
#     tDeterministicForecast = PSY.Deterministic("scalingfactor", forecast_data)
#     @test tDeterministicForecast isa PowerSystems.Forecast
#     #Probabilistic Tests
#     tProbabilisticForecast = PSY.Probabilistic("scalingfactor", Hour(1), DateTime("01-01-01"),[0.5, 0.5], 24)
#     @test  tProbabilisticForecast isa PowerSystems.Forecast
#     tProbabilisticForecast = PSY.Probabilistic("scalingfactor", [1.0], forecast_data)
#     @test  tProbabilisticForecast isa PowerSystems.Forecast
#     #Scenario Tests
#     tScenarioForecast = PSY.ScenarioBased("scalingfactor", Hour(1), DateTime("01-01-01"), 2, 24)
#     @test  tScenarioForecast isa PowerSystems.Forecast
#     tScenarioForecast = PSY.ScenarioBased("scalingfactor",forecast_data)
#     @test  tScenarioForecast isa PowerSystems.Forecast
# end
