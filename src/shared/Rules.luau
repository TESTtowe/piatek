local Rules = {}

function Rules.exactArray(value, expected)
    if type(value) ~= "table" or #value ~= #expected then return false end
    local count = 0
    for k in pairs(value) do
        if type(k) ~= "number" or k % 1 ~= 0 or k < 1 or k > #expected then return false end
        count += 1
    end
    if count ~= #expected then return false end
    for i, id in ipairs(expected) do if value[i] ~= id then return false end end
    return true
end

function Rules.checkPuzzle(definition, answer, memorySelection)
    if type(answer) ~= "table" then return false end
    if definition.kind == "order" then
        return Rules.exactArray(answer, definition.solution)
    elseif definition.kind == "classify" then
        local count = 0
        for _ in pairs(answer) do count += 1 end
        if count ~= #definition.cards then return false end
        for _, card in ipairs(definition.cards) do
            if answer[card.id] ~= card.answer then return false end
        end
        return true
    elseif definition.kind == "memory" then
        if not memorySelection then return false end
        local sortedAnswer = {}
        for k, v in pairs(answer) do
            if type(k) ~= "number" or k < 1 or k % 1 ~= 0 or k > #memorySelection or type(v) ~= "string" then return false end
            table.insert(sortedAnswer, v)
        end
        if #sortedAnswer ~= #memorySelection then return false end
        local sortedExpected = table.clone(memorySelection)
        table.sort(sortedAnswer)
        table.sort(sortedExpected)
        return Rules.exactArray(sortedAnswer, sortedExpected)
    end
    return false
end

function Rules.validSaved(data, campaign)
    if type(data) ~= "table" or data.version ~= 1 then return false end
    if type(data.chapter) ~= "number" or data.chapter % 1 ~= 0 or data.chapter < 1 or data.chapter > #campaign.chapters then return false end
    if type(data.step) ~= "number" or data.step % 1 ~= 0 or data.step < 1 or data.step > #campaign.chapters[data.chapter].objectives then return false end
    if type(data.scores) ~= "table" or type(data.journal) ~= "table" or type(data.choices) ~= "table" or type(data.completed) ~= "boolean" then return false end
    for _, key in ipairs({ "empathy", "clarity", "community" }) do
        if type(data.scores[key]) ~= "number" or data.scores[key] ~= data.scores[key] or data.scores[key] < 0 or data.scores[key] > 100 then return false end
    end
    local count = 0
    for _ in pairs(data.journal) do count += 1 end
    if count > 40 then return false end
    for key, entry in pairs(data.journal) do
        if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > count or type(entry) ~= "string" or #entry > 2000 then return false end
    end
    if #data.journal ~= count then return false end
    local validChoices = {}
    for _, chapter in ipairs(campaign.chapters) do
        for _, objective in ipairs(chapter.objectives) do
            if objective.choices then
                validChoices[objective.id] = {}
                for _, option in ipairs(objective.choices) do validChoices[objective.id][option.id] = true end
            end
        end
    end
    for key, value in pairs(data.choices) do
        if type(key) ~= "string" or type(value) ~= "string" or not validChoices[key] or not validChoices[key][value] then return false end
    end
    return true
end

return Rules
