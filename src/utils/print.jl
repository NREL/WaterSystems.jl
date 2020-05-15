
function Base.summary(tech::TechnicalParams)
    return "$(typeof(tech))"
end

function Base.summary(sys::System)
    try
        return "System with $(sys.junctions) junctions and $(sys.arcs)"
    catch
        return "System (empty)"
    end
end

# function Base.show(io::IO, sys::System)
#     println(io, "basepower=$(sys.basepower)")
#     show(io, sys.data)
# end

# function Base.show(io::IO, ::MIME"text/plain", sys::System)
#     println(io, "System")
#     println(io, "======")
#     println(io, "Base Power: $(sys.basepower)\n")
#     show(io, MIME"text/plain"(), sys.data)
# end

# function Base.show(io::IO, ::MIME"text/html", sys::System)
#     println(io, "<h1>System</h1>")
#     println(io, "<p><b>Base Power</b>: $(sys.basepower)</p>")
#     show(io, MIME"text/html"(), sys.data)
# end
