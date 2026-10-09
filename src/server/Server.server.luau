local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local Shared = ReplicatedStorage:WaitForChild("Friday")
local Config = require(Shared:WaitForChild("Config"))
local Campaign = require(Shared:WaitForChild("Campaign"))
local Engine = require(Shared:WaitForChild("Engine"))
local Rules = require(Shared:WaitForChild("Rules"))
local Gate = require(Shared:WaitForChild("Gate"))
local WorldData = require(Shared:WaitForChild("WorldData"))
local World = require(script.Parent:WaitForChild("World"))

local network = Instance.new("Folder")
network.Name = "Network"
network.Parent = Shared
local command = Instance.new("RemoteEvent")
command.Name = "Command"
command.Parent = network
local event = Instance.new("RemoteEvent")
event.Name = "Event"
event.Parent = network

local sessions, handles = {}, {}
local store = Config.PersistenceEnabled and DataStoreService:GetDataStore(Config.DataStoreName) or nil
local function send(player, kind, payload) event:FireClient(player, kind, payload) end

local function snapshot(player)
    local session = sessions[player]
    if not session then return end
    local state = session.state
    local done, total = Engine.progress(state, Campaign)
    local endingTitle, endingText = Engine.ending(state)
    send(player, "State", { chapter = state.chapter, step = state.step, started = session.started,
        completed = state.completed, journal = state.journal, scores = state.scores,
        done = done, total = total, saving = session.saving, loadWarning = session.loadWarning,
        endingTitle = endingTitle, endingText = endingText })
end

local function persist(player)
    local session = sessions[player]
    if not store or not session or session.noSave then return end
    session.dirty = true
    if session.savingNow then return end
    session.savingNow = true
    -- Współbieżne żądania współdzielą jedną kolejkę zapisu; końcowy postęp nie jest pomijany.
    while session.dirty do
        session.dirty = false
        local record = HttpService:JSONDecode(HttpService:JSONEncode(session.state))
        local ok = pcall(function() store:UpdateAsync("player_" .. player.UserId, function() return record end) end)
        session.saving = ok and "saved" or "failed"
        if not ok then warn("Friday: zapis postępu nie powiódł się dla gracza " .. player.UserId) end
    end
    session.savingNow = false
    if player.Parent then snapshot(player) end
end

local function distanceOk(player, target)
    local character = player.Character
    local pivot = character and character:FindFirstChild("HumanoidRootPart")
    local handle = handles[target]
    return pivot ~= nil and handle ~= nil and (pivot.Position - handle.Position).Magnitude <= Config.InteractionDistance
end

local function advance(player, selected)
    local session = sessions[player]
    local chapterBefore = session.state.chapter
    if not Engine.advance(session.state, Campaign, selected) then return false end
    session.active = nil
    snapshot(player)
    if session.state.chapter ~= chapterBefore then
        send(player, "Chapter", { index = session.state.chapter })
    end
    task.spawn(persist, player)
    return true
end

local function interact(player, id)
    local session = sessions[player]
    if not session or not session.started or session.state.completed then return end
    if os.clock() - session.lastInteraction < 0.6 then return end
    session.lastInteraction = os.clock()
    local objective = Engine.objective(session.state, Campaign)
    if id ~= objective.target then
        send(player, "Toast", "Teraz: " .. objective.title)
        return
    end
    if not distanceOk(player, id) then return end
    if session.active and os.clock() - session.active.opened < Config.ChallengeLifetime then return end
    local active = { token = HttpService:GenerateGUID(false), objective = objective.id,
        opened = os.clock(), target = id }
    session.active = active
    if objective.kind == "dialogue" then
        send(player, "Dialogue", { objective = objective, token = active.token })
    elseif objective.kind == "puzzle" then
        local definition = Campaign.puzzles[objective.puzzle]
        if definition.kind == "memory" then
            local ids = {}
            for _, card in ipairs(definition.cards) do table.insert(ids, card.id) end
            for i = #ids, 2, -1 do local j = math.random(i); ids[i], ids[j] = ids[j], ids[i] end
            active.memory = {}
            for i = 1, definition.count do table.insert(active.memory, ids[i]) end
        end
        send(player, "Puzzle", { id = objective.puzzle, token = active.token, memory = active.memory })
    else
        advance(player)
        send(player, "Toast", objective.journal)
    end
end

handles = World.build(interact)

local function initialize(player)
    local session = { state = Engine.new(), started = false, lastCommand = 0, lastInteraction = -1,
        saving = store and "idle" or "session", loaded = false }
    sessions[player] = session
    if store then
        local ok, saved = pcall(function() return store:GetAsync("player_" .. player.UserId) end)
        if ok and saved ~= nil and Rules.validSaved(saved, Campaign) then
            session.state = saved
        elseif not ok or saved ~= nil then
            session.noSave = true
            session.loadWarning = "Nie udało się odczytać postępu. Ta sesja nie nadpisze wcześniejszego zapisu."
        end
    end
    session.loaded = true
    snapshot(player)
end

Players.PlayerAdded:Connect(initialize)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(initialize, player) end
Players.PlayerRemoving:Connect(function(player)
    persist(player)
    sessions[player] = nil
end)

command.OnServerEvent:Connect(function(player, action, payload)
    local session = sessions[player]
    if not session or not session.loaded or type(action) ~= "string" then return end
    if os.clock() - session.lastCommand < 0.12 then return end
    session.lastCommand = os.clock()
    if action == "Sync" then snapshot(player); return end
    if action == "Start" then
        if session.started then return end
        session.started = true
        snapshot(player)
        send(player, "Chapter", { index = session.state.chapter })
        return
    end
    if action == "Reset" then
        -- UI prosi o drugie kliknięcie przed wysłaniem; każdy gracz resetuje tylko siebie.
        session.state = Engine.new()
        session.active = nil
        session.started = false
        session.lastInteraction = -1
        local character = player.Character
        if character then character:PivotTo(CFrame.new(table.unpack(WorldData.spawn))) end
        snapshot(player)
        task.spawn(persist, player)
        return
    end
    if not session.started or type(payload) ~= "table" then return end
    local active = session.active
    local objective = Engine.objective(session.state, Campaign)
    local verdict = Gate.validate(session, objective, payload, os.clock(), Config.ChallengeLifetime, active and distanceOk(player, active.target))
    if verdict == "invalid" then return end
    if verdict == "expired" then
        session.active = nil
        send(player, "Expired", "Rozmowa wygasła. Podejdź ponownie do znacznika.")
        return
    end
    if action == "Cancel" then session.active = nil; return end
    if verdict == "distance" then
        session.active = nil
        send(player, "Expired", "Wróć do miejsca zadania i spróbuj ponownie.")
        return
    end
    if verdict == "early" then return end
    if action == "Choice" and objective.kind == "dialogue" and type(payload.choice) == "string" then
        local selected
        for _, option in ipairs(objective.choices) do if option.id == payload.choice then selected = option end end
        if selected then
            send(player, "Reply", { text = selected.reply })
            advance(player, payload.choice)
        end
    elseif action == "Solve" and objective.kind == "puzzle" then
        local definition = Campaign.puzzles[objective.puzzle]
        if definition.kind == "memory" and os.clock() - active.opened < 7 then
            send(player, "PuzzleResult", { ok = false, message = "Najpierw obejrzyj całą listę." })
            return
        end
        if Rules.checkPuzzle(definition, payload.answer, active.memory) then
            send(player, "PuzzleResult", { ok = true, message = "Zapis gotowy. Możesz wrócić do rozmowy." })
            advance(player)
        else
            send(player, "PuzzleResult", { ok = false, message = "Jeszcze nie pasuje. Sprawdź karty i spróbuj ponownie." })
        end
    end
end)

game:BindToClose(function()
    local remaining = 0
    for player in pairs(sessions) do
        remaining += 1
        task.spawn(function()
            local session = sessions[player]
            persist(player)
            local timeout = os.clock() + 18
            while session and session.savingNow and os.clock() < timeout do task.wait(0.1) end
            remaining -= 1
        end)
    end
    local deadline = os.clock() + 20
    while remaining > 0 and os.clock() < deadline do task.wait(0.1) end
end)
