import UUIDs

""" Internal storage common to WaterSystems types."""

struct WaterSystemInternal
    uuid:: Base.UUID
end

""" Creates WaterSystemInternal with a UUID.""" 

WaterSystemInternal() = WaterSystemInternal(UUIDs.uuid4())

""" Gets the UUID for any WaterSystemType."""

function get_uuid(obj::WaterSystemType)::Base.UUID
    return obj.internal.uuid
end
