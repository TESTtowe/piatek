local Campaign = require("../src/shared/Campaign")
local Engine = require("../src/shared/Engine")
local Rules = require("../src/shared/Rules")
local Gate = require("../src/shared/Gate")
local World = require("../src/shared/WorldData")
local Facts = require("../src/shared/FactBook")
local passed, failed = 0, 0

local function test(name, callback)
    local ok, result = pcall(callback)
    if ok then passed += 1; print("PASS " .. name)
    else failed += 1; print("FAIL " .. name .. ": " .. tostring(result)) end
end

local function equal(actual, expected)
    assert(actual == expected, "expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

test("campaign references are complete and objective IDs unique", function()
    local ids = {}
    for _, chapter in ipairs(Campaign.chapters) do
        assert(#chapter.objectives > 0)
        for _, objective in ipairs(chapter.objectives) do
            assert(not ids[objective.id], "duplicate " .. objective.id)
            ids[objective.id] = true
            assert(World.targets[objective.target], "missing target " .. objective.target)
            assert(type(objective.journal) == "string" and #objective.journal > 0)
            if objective.kind == "dialogue" then
                assert(#objective.lines > 0 and #objective.choices > 0)
                local choices = {}
                for _, option in ipairs(objective.choices) do
                    assert(not choices[option.id])
                    choices[option.id] = true
                    assert(#option.reply > 0)
                end
            elseif objective.kind == "puzzle" then
                assert(Campaign.puzzles[objective.puzzle])
            else equal(objective.kind, "collect") end
        end
    end
end)

test("all interaction points are reachable inside the map bounds", function()
    for id, target in pairs(World.targets) do
        local x, y, z = table.unpack(target.position)
        assert(x > -76 and x < 76 and z > -64 and z < 98 and y > 0, id)
    end
end)

test("every factual card has a public source and a publication date", function()
    assert(#Facts.entries >= 16)
    for _, entry in ipairs(Facts.entries) do
        local source = Facts.sources[entry.source]
        assert(source and source.url:match("^https://"))
        assert(source.date:match("%d%d%.%d%d%.%d%d%d%d"))
        assert(#entry.text > 50 and #entry.category > 0)
    end
end)

test("full campaign executes all 19 objectives and preserves every checkpoint", function()
    local state = Engine.new()
    local completed = 0
    while not state.completed do
        local objective = Engine.objective(state, Campaign)
        local done, total = Engine.progress(state, Campaign)
        equal(done, completed)
        equal(total, 19)
        assert(Rules.validSaved(state, Campaign))
        assert(Engine.advance(state, Campaign, objective.choices and objective.choices[1].id or nil))
        completed += 1
    end
    equal(completed, 19)
    equal(#state.journal, 19)
    local done, total = Engine.progress(state, Campaign)
    equal(done, total)
    equal(Engine.objective(state, Campaign), nil)
    equal(Engine.advance(state, Campaign), false)
    assert(Rules.validSaved(state, Campaign))
end)

test("every dialogue choice records its own effects and rejects unknown options", function()
    for chapterIndex, chapter in ipairs(Campaign.chapters) do
        for step, objective in ipairs(chapter.objectives) do
            if objective.choices then
                for _, option in ipairs(objective.choices) do
                    local state = Engine.new()
                    state.chapter, state.step = chapterIndex, step
                    equal(Engine.advance(state, Campaign, "invented"), false)
                    equal(#state.journal, 0)
                    assert(Engine.advance(state, Campaign, option.id))
                    equal(state.choices[objective.id], option.id)
                    for _, key in ipairs({ "empathy", "clarity", "community" }) do equal(state.scores[key], option.score[key] or 0) end
                end
            end
        end
    end
end)

test("independent player state cannot leak choices or journal entries", function()
    local first, second = Engine.new(), Engine.new()
    Engine.advance(first, Campaign, "together")
    equal(second.step, 1)
    equal(second.scores.empathy, 0)
    equal(#second.journal, 0)
end)

test("all ordered puzzles accept intended order and reject permutations", function()
    for _, puzzle in pairs(Campaign.puzzles) do
        if puzzle.kind == "order" then
            assert(Rules.checkPuzzle(puzzle, table.clone(puzzle.solution)))
            local wrong = table.clone(puzzle.solution)
            wrong[1], wrong[2] = wrong[2], wrong[1]
            equal(Rules.checkPuzzle(puzzle, wrong), false)
            equal(Rules.checkPuzzle(puzzle, {}), false)
            local extra = table.clone(puzzle.solution)
            extra.extra = true
            equal(Rules.checkPuzzle(puzzle, extra), false)
        end
    end
end)

test("source classification checks all cards, not a client completion flag", function()
    local def = Campaign.puzzles.sources
    local correct = {}
    for _, card in ipairs(def.cards) do correct[card.id] = card.answer end
    assert(Rules.checkPuzzle(def, correct))
    correct.screenshot = "verified"
    equal(Rules.checkPuzzle(def, correct), false)
    equal(Rules.checkPuzzle(def, { success = true }), false)
    equal(Rules.checkPuzzle(def, "success"), false)
end)

test("memory puzzle rejects duplicates, extra keys and missing names", function()
    local def = Campaign.puzzles.attendance
    local selected = { "lena", "olek", "iga" }
    assert(Rules.checkPuzzle(def, { "iga", "lena", "olek" }, selected))
    equal(Rules.checkPuzzle(def, { "lena", "lena", "olek" }, selected), false)
    equal(Rules.checkPuzzle(def, { "lena", "olek" }, selected), false)
    equal(Rules.checkPuzzle(def, { "lena", "olek", "iga", extra = "maja" }, selected), false)
    equal(Rules.checkPuzzle(def, { "lena", false, "iga" }, selected), false)
    equal(Rules.checkPuzzle(def, selected, nil), false)
end)

test("challenge validation rejects replay, stale objective, expiry, distance and early submission", function()
    local objective = { id = "schedule" }
    local session = { started = true, active = { token = "server-token", objective = "schedule", opened = 10 } }
    local function verdict(payload, now, nearby) return Gate.validate(session, objective, payload, now, 180, nearby) end
    equal(verdict({ token = "server-token" }, 12, true), "valid")
    equal(verdict({ token = "other-token" }, 12, true), "invalid")
    equal(verdict({ token = "server-token" }, 10.5, true), "early")
    equal(verdict({ token = "server-token" }, 191, true), "expired")
    equal(verdict({ token = "server-token" }, 12, false), "distance")
    session.active.objective = "different"
    equal(verdict({ token = "server-token" }, 12, true), "invalid")
    session.active = nil
    equal(verdict({ token = "server-token" }, 12, true), "invalid")
end)

test("invalid persisted state cannot index campaign or inject arbitrary choices", function()
    equal(Rules.validSaved(nil, Campaign), false)
    local state = Engine.new()
    assert(Rules.validSaved(state, Campaign))
    state.chapter = 500
    equal(Rules.validSaved(state, Campaign), false)
    state.chapter = 1
    state.scores.empathy = 0 / 0
    equal(Rules.validSaved(state, Campaign), false)
    state.scores.empathy = 0
    state.choices.fake = "made-up"
    equal(Rules.validSaved(state, Campaign), false)
    state.choices = {}
    state.journal.hidden = "not an array"
    equal(Rules.validSaved(state, Campaign), false)
end)

test("three epilogues remain selectable and ties are deterministic", function()
    local state = Engine.new()
    equal(Engine.ending(state), "OBECNOŚĆ")
    state.scores = { empathy = 2, clarity = 5, community = 1 }
    equal(Engine.ending(state), "UCZCIWE SŁOWA")
    state.scores = { empathy = 2, clarity = 3, community = 6 }
    equal(Engine.ending(state), "WSPÓLNE JUTRO")
    state.scores = { empathy = 5, clarity = 5, community = 0 }
    equal(Engine.ending(state), "OBECNOŚĆ")
end)

print(string.format("RESULT: %d passed, %d failed", passed, failed))
if failed > 0 then error("Campaign checks failed") end
