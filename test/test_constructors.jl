

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
