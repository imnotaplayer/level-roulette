local time = os.time()

math.randomseed(time) -- for a random result

local d = {}
local list = {}

-- get the current active list
local f = io.open("Remaining-List.txt", "rb")
if f then
    for line in f:lines() do
        if line:len() > 1 then
            table.insert(d, line)
        end
    end
    f:close()
else
    print("Created Remaining-List.txt. The List will be empty.")
    -- this is a bit questionable.
    -- i believe it repeatedly overwrite on a write-only system.
    local f = io.open("Remaining-List.txt", "w")
    if f then
        f:write("\n")
        f:close()
    else
        print("Failed to create Remaining-List.txt")
    end
end
-- get the current saved list
local f = io.open("The-List.txt", "rb")
if f then
    for line in f:lines() do
        if line:len() > 1 then
            table.insert(list, line)
        end
    end
    f:close()
else
    print("Created The-List.txt")
    -- same here.
    local f = io.open("The-List.txt", "w")
    if f then
        f:write("\n")
        f:close()
    else
        print("Failed to create The-List.txt")
    end
end

f = nil

-- info message
if #d == 0 then
    print('New levels can be added with the "add <level>" command or by adding to Remaining-List.txt and adding each level on it\'s '..
          'own line and restarting the application.')
    print('Levels can also be removed with the "remove <level>" command or by removing from Remaining-List.txt')
    print('You can change your current list of levels to your chosen levels with "swap"\n'..
          'If you want to keep a backup of your list, I suggest making one before using this command, this isn\'t reverseable.')
end

-- saves the list and remaining levels to files
local function save()
    do
        local s = table.concat(d, "\n")
        local f = io.open("Remaining-List.txt", "wb")
        f:write(s, "\n")
        f:close()
    end
    do
        local s = table.concat(list, "\n")
        local f = io.open("The-List.txt", "wb")
        f:write(s, "\n")
        f:close()
    end
end

-- main loop
while true do
    local i = io.read()
    if i == "" or i == "next" or i == "continue" then
        -- <d> is the active list that levels will be chosen from
        -- <list> is the list of levels that will be swapped to with the "swap" command
        if #d == 0 then
            print("There are no levels left in the active list.")
            if #list > 0 then
                print('Type "swap" to swap your active list with your saved list')
            end
        else
            local c = math.random(1, #d)
            local n = d[c]
            print(n)
            io.write("Add to The List? (y/n) ")
            local i = io.read():lower()
            if i:sub(1, 1) == "y" then
                table.insert(list, n)
                print(#list.." "..(#list == 1 and "entry" or "entries").." now on The List.")
            else
                print("Skipped level.")
            end
            table.remove(d, c)
            save()
        end
    elseif i == "list" then
        save()
        if #list == 0 then
            print("The List: (..empty..)")
        else
            print("The List: "..table.concat(list))
        end
		if #d == 0 then
			print("Remaining: (..none..)")
		else
            print("Remaining: "..table.concat(d))
		end
    elseif i:sub(1, 4) == "add " then
        local level = i:sub(5, -1)
        local valid = true
        for k, v in ipairs(d) do
            if v:lower() == level:lower() then
                valid = false
                break
            end
        end
        if valid then
            for k, v in ipairs(list) do
                if v:lower() == level:lower() then
                    valid = false
                    break
                end
            end
        end
        if valid then
            table.insert(d, level)
            print("Added "..level.." to active list.")
            save()
        else
            -- is this misleading?
            print("Level already accounted for.")
        end
    elseif i:sub(1, 7) == "remove " then
        local level = i:sub(8, -1)
        local valid = false
        for k, v in ipairs(d) do
            if v:lower() == level:lower() then
                valid = k
                break
            end
        end
        if valid then
            local level = table.remove(d, valid)
            print("Removed "..level.." from active list.")
            save()
        else
            print("Level not in list.")
        end
    elseif i == "swap" then
        d = list
        list = {}
        -- is this misleading?
        print("Swapped active list with saved list.")
        -- save()
    elseif i == "exit" or i == "quit" then
        -- unlike breaking with CTRL+C, this will save before exiting,
        -- which may or may not be desirable
        save()
        os.exit()
    end
end
