filepath = Base.source_path()

using Pkg
Pkg.activate( joinpath(dirname(filepath),"..") )
Pkg.activate

import InfrastructureSystems
const IS = InfrastructureSystems

function main(args)
    if length(args) != 2
        println("CLI usage: julia generate_structs.jl INPUT_FILE OUTPUT_DIRECTORY")
        println("REPL usage: IS.generate_structs(INPUT_FILE OUTPUT_DIRECTORY)")
        return
    end

    IS.generate_structs(args[1], args[2])
end

main(ARGS)
