local function getKeys(tab)
    local keys = {}
    for key, _ in pairs(tab) do
        table.insert(keys, key)
    end
    return keys
end

local function getValues(tab)
	local values = {}
	for _, value in pairs(tab) do
		table.insert(values, value)
	end
	return values
end

local function loadGrammar(filePath)
    local transitions = {}
    local moves = {}
    for line in io.lines(filePath) do
        local parts = {}
        for part in line:gmatch("[^,]+") do
            table.insert(parts, part)
        end

        if parts[1] == "transition" and #parts == 4 then
            transitions[parts[2]] = transitions[parts[2]] or {}
            transitions[parts[2]][parts[3]] = parts[4]
		elseif parts[1] == "move" and #parts == 3 then
            moves[parts[2]] = parts[3]
		end
    end

    return transitions, moves
end

local transitionsFromFile, movesFromFile = loadGrammar("ft_ality.gmr")
-- Définition de l'automate
local Automaton = {
    currentState = "start",
    transitions = transitionsFromFile,
	moves = movesFromFile,
    transition = function(self, key)
        local nextState = self.transitions[self.currentState][key]
        if nextState then
            self.currentState = nextState
            if self.moves[nextState] then
                print("Special Move Detected: " .. self.moves[nextState])
                self.currentState = "start" -- Reset state after a move
            end
        else
            self.currentState = "start" -- Reset state if invalid key
        end
    end,
	displayActions = function(self)
		if self.transitions.start then
			print("Available actions: " .. table.concat(getKeys(self.transitions.start), ", "))
		else
			print("No available actions for the start state.")
		end
	end,
	displayTransitions = function(self)
		print("Transitions: ")
		for state, transitions in pairs(self.transitions) do
			local t = {}
			for key, nextState in pairs(transitions) do
				table.insert(t, key .. " -> " .. nextState)
			end
			print(state .. ": " .. table.concat(t, ", "))
		end
	end,
	displayMoves = function(self)
		print("Special Moves: " .. table.concat(getValues(self.moves), ", "))
	end
}

Automaton:displayActions()
Automaton:displayTransitions()
Automaton:displayMoves()

-- Programme principal
while true do
    print("\nEnter your move sequence ('f', 'd', 'p', 'k', or 'quit' to exit): ")
	print("Current state : " .. Automaton.currentState)
    local input = io.read() -- Lecture de la séquence de l'utilisateur
    if input == "quit" then break end -- Sortie du programme
    for i = 1, #input do
        local key = input:sub(i, i)
        Automaton:transition(key)
    end
end

