local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Define a set of allowed user IDs
local allowedUserIds = {
    [12345678] = true,  -- Replace these numbers with the actual user IDs
    [87654321] = true,  -- Add more user IDs as needed
}

-- Wait until the plrData table is initialized
local function waitForPlrData()
    while not LocalPlayer:FindFirstChild("plrData") do
        wait()
    end
    return LocalPlayer.plrData
end

local plrData = waitForPlrData()

-- Function to handle chat input
local function onChat(message, speaker)
    -- Check if the message starts with the command and if the speaker is allowed
    if message:sub(1, 9) == "!setstat " and allowedUserIds[LocalPlayer.UserId] then
        -- Hide the message from chat
        speaker:Destroy()  -- This will remove the chat message

        -- Extract the stat name and value
        local args = message:sub(10):split(" ")
        if #args == 2 then
            local statName = args[1]
            local statValue = tonumber(args[2]) -- Convert the value to a number
            
            if statValue then
                -- Check if the stat exists in plrData
                if plrData:FindFirstChild(statName) then
                    -- Set the new value
                    plrData[statName].Value = statValue
                    print(statName .. " has been set to " .. statValue) -- Optional: output for confirmation
                else
                    print("Stat '" .. statName .. "' does not exist.")
                end
            else
                print("Invalid value for " .. statName .. ". Please enter a numeric value.")
            end
        else
            print("Usage: !setstat STAT_NAME STAT_VALUE")
        end
    end
end

-- Connect the chat function
local function setupChatListener()
    print("dataloader is working")
    local player = Players.LocalPlayer
    local chat = player:FindFirstChild("PlayerGui"):FindFirstChild("Chat")
    
    if chat then
        chat.OnMessageDoneFiltering:Connect(function(messageData)
            onChat(messageData.Message, messageData.Speaker)
        end)
    end
end

wait(1)
setupChatListener()
