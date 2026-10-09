-- Czysta maszyna stanów: testowalna bez Roblox Studio i bez usług sieciowych.
local Engine = {}

function Engine.new()
    return { version = 1, chapter = 1, step = 1, completed = false,
        scores = { empathy = 0, clarity = 0, community = 0 }, journal = {}, choices = {} }
end

function Engine.objective(state, campaign)
    if state.completed then return nil end
    return campaign.chapters[state.chapter].objectives[state.step]
end

function Engine.advance(state, campaign, selectedChoice)
    local objective = Engine.objective(state, campaign)
    if not objective then return false end
    if objective.kind == "dialogue" then
        local selected
        for _, option in ipairs(objective.choices) do if option.id == selectedChoice then selected = option end end
        if not selected then return false end
        state.choices[objective.id] = selected.id
        for key, amount in pairs(selected.score) do state.scores[key] += amount end
    elseif selectedChoice ~= nil then
        return false
    end
    table.insert(state.journal, objective.journal)
    local chapter = campaign.chapters[state.chapter]
    if state.step < #chapter.objectives then
        state.step += 1
    elseif state.chapter < #campaign.chapters then
        state.chapter += 1
        state.step = 1
    else
        state.completed = true
    end
    return true
end

function Engine.progress(state, campaign)
    local total, done = 0, 0
    for index, chapter in ipairs(campaign.chapters) do
        total += #chapter.objectives
        if index < state.chapter then done += #chapter.objectives end
    end
    done += state.step - 1
    if state.completed then done = total end
    return done, total
end

function Engine.ending(state)
    local s = state.scores
    if s.empathy >= s.clarity and s.empathy >= s.community then
        return "OBECNOŚĆ", "Lena pamięta, że nikt jej nie pospieszał. Olek pamięta rozmowę bez osądzania. Na ostatniej stronie zostaje miejsce dla ludzi, którzy potrzebują czasu."
    elseif s.clarity >= s.community then
        return "UCZCIWE SŁOWA", "Archiwum odróżnia zapisy od domysłów. Olek dopisał sprostowanie. Puste miejsca nie udają odpowiedzi. Zeszyt można otworzyć ponownie, kiedy pojawią się sprawdzone źródła."
    end
    return "WSPÓLNE JUTRO", "Wystawa nie została dokończona. Została grupa, która chce wrócić do rozmowy. Każdy może zdecydować, jaką część swojej historii zostawi na kolejnej stronie."
end

return Engine
