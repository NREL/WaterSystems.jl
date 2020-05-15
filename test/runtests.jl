# using packages that provide functionality for testing
using Test
using Logging
using TestSetExtensions
# import this package and its dependencies
#import TimeSeries
#import DataFrames
import InfrastructureSystems
const IS = InfrastructureSystems
import WaterSystems
const WSY = WaterSystems

const LOG_FILE = "water-systems-test.log"

LOG_LEVELS = Dict(
    "Debug" => Logging.Debug,
    "Info" => Logging.Info,
    "Warn" => Logging.Warn,
    "Error" => Logging.Error,
)

function get_logging_level(env_name::String, default)
    level = get(ENV, env_name, default)
    log_level = get(LOG_LEVELS, level, nothing)
    if isnothing(log_level)
        error("Invalid log level $level: Supported levels: $(values(LOG_LEVELS))")
    end

    return log_level
end

function run_tests()
    console_level = get_logging_level("SYS_CONSOLE_LOG_LEVEL", "Error")
    console_logger = ConsoleLogger(stderr, console_level)
    file_level = get_logging_level("SYS_LOG_LEVEL", "Info")

    IS.open_file_logger(LOG_FILE, file_level) do file_logger
        multi_logger = IS.MultiLogger(
            [console_logger, file_logger],
            IS.LogEventTracker((Logging.Info, Logging.Warn, Logging.Error)),
        )
        global_logger(multi_logger)

        include("test_utils/get_test_data.jl")

        @time @testset "Begin WaterSystems tests" begin
            @includetests ARGS
        end

        # TODO: Enable this once all expected errors are not logged.
        #@test length(IS.get_log_events(multi_logger.tracker, Logging.Error)) == 0

        @info IS.report_log_summary(multi_logger)
    end
end

logger = global_logger()

try
    run_tests()
finally
    # Guarantee that the global logger is reset.
    global_logger(logger)
    nothing
end



## old tests -- probably do not work, JJS 12/19/19
# println("Read data from WNTR networks 1, 2, and 3.")
# #@time @test include(joinpath(TEST_DIR, "readnetworkdata.jl"))
# println("Test all constructors.")
# @time @test include(joinpath(TEST_DIR, "constructors.jl"))
# println("Test Network Struct.")
# @time @test include(joinpath(TEST_DIR, "network.jl"))
# println("Test WaterSystem struct.")
# @time @test include(joinpath(TEST_DIR, "watersystem.jl"))
# println("Test wntr parser.")
# @time @test include(joinpath(TEST_DIR, "test_dict_parser.jl"))
# @test true

