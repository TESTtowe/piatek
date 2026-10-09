-- Żądanie klienta jest tylko prośbą. Serwer pozostaje właścicielem stanu.
local Gate = {}

function Gate.validate(session, objective, payload, now, lifetime, nearby)
    if not session or not session.started or not objective or type(payload) ~= "table" then return "invalid" end
    local active = session.active
    if not active or active.objective ~= objective.id or type(payload.token) ~= "string" or payload.token ~= active.token then return "invalid" end
    if now - active.opened > lifetime then return "expired" end
    if not nearby then return "distance" end
    if now - active.opened < 1 then return "early" end
    return "valid"
end

return Gate
