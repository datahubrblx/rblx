-- Script by: Rynzite

local ChatSystem = script.Parent
local ChatMessageTemplate = ChatSystem.MessageTemplate
local EnterChat = ChatSystem.Chatbox
local OpenChatButton = ChatSystem.Parent.FakeRobloxUnibar.UnibarMenu:FindFirstChild("1"):FindFirstChild("2").ToggleChat
local ChatFrame: ScrollingFrame = ChatSystem.ChatList
local Player = game.Players.LocalPlayer
local util = require(game:GetService("ReplicatedStorage"):FindFirstChild("Modules"):WaitForChild("util"))
local adminCmdEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Events"):FindFirstChild("adminCmdEvent")

local filteredWords = {
	"wanker", "goddam", "godsdamn", "fuck", "frigger", "fatherfucker",
	"turd", "twat", "sweet jesus", "spastic", "son of a bitch", "son of a whore", "slut",
	"sisterfucker", "shite", "shit ass", "shit", "dyke", "dickhead", "dick", "damn it", "damn",
	"pussy", "prick", "piss", "pigfucker", "cunt", "crap", "cocksucker", "cock",
	"Christ on a cracker", "Christ on a bike", "child-fucker", "child fucker", "childfucker",
	"nigra", "nigga", "nigger", "motherfucker", "bullshit", "bugger", "brotherfucker", "bollocks",
	"bloody", "bitch", "bastard", "kike", "Jesus wept", "Jesus, Mary and Joseph", "Jesus Harold Christ",
	"Jesus H. Christ", "Jesus H Christ", "Jesus fuck", "Jesus Christ", "asshole",
	"ass", "azz", "arsehole", "arsehead", "arse", "in shit", "holy shit", "horseshit"
	-- Add more filtered words as needed
}

local visibleMessages = {}
local transparency = 0
local fadeOutActive = false
local lastActivity = tick()
local FADE_INTERVAL = 0.01
local FADE_DELAY = 5
local maxMessages = 50
local minMessagesToAutoScroll = 8

local function fadeChat()
	while true do
		wait(FADE_INTERVAL)
		if tick() - lastActivity >= FADE_DELAY and not fadeOutActive and ChatSystem.Visible then
			fadeOutActive = true
			for i = transparency, 1, FADE_INTERVAL do
				if tick() - lastActivity < FADE_DELAY then
					-- User interacted, stop fading
					break
				end
				transparency = i
				ChatSystem.ImageTransparency = transparency
				wait(FADE_INTERVAL)
			end
			fadeOutActive = false
		end
		
		if ChatSystem.ImageTransparency == 1 then
			ChatSystem.Visible = false
			ChatSystem.ImageTransparency = 0
			transparency = 0
		end
	end
end

local function resetFade()
	lastActivity = tick()
	if fadeOutActive then
		fadeOutActive = false -- Stop any ongoing fade process
	end
	for i = transparency, 0, -FADE_INTERVAL do
		transparency = i
		ChatSystem.ImageTransparency = transparency
		wait(FADE_INTERVAL)
	end
	transparency = 0
end

local function createCaseInsensitivePattern(word)
    local pattern = ""
    for i = 1, #word do
        local char = word:sub(i, i)
        local upperChar = char:upper()
        local lowerChar = char:lower()
        if char == upperChar then
            pattern = pattern .. "[" .. upperChar .. lowerChar .. "]"
        elseif char == lowerChar then
            pattern = pattern .. "[" .. upperChar .. lowerChar .. "]"
        else
            pattern = pattern .. char
        end
    end
    return pattern
end

local function toggleChatVisibility()
	ChatSystem.Visible = not ChatSystem.Visible
	
	if ChatSystem.Visible then
		resetFade()
	end
end

OpenChatButton.MouseButton1Click:Connect(toggleChatVisibility)

local function createNewChatMessage(player, messageText)
	-- If the size of 'visibleMessages' is greater than maxMessages then remove the oldest message
	if #visibleMessages > maxMessages then
		visibleMessages[1]:Destroy() -- Remove the oldest message from the UI
		table.remove(visibleMessages, 1) -- Remove the oldest entry from the table
	end

	local newMessage = ChatMessageTemplate:Clone()

	for _, word in ipairs(filteredWords) do
		local pattern = createCaseInsensitivePattern(word)
		messageText = messageText:gsub(pattern, string.rep("*", #word))
	end

	if player == "System" then
		newMessage.Text = "[SYSTEM]: "..messageText
		newMessage.TextColor3 = Color3.new(0.737255, 0.737255, 0.737255)
	elseif player:IsA("Player") then
		-- Attempt to fetch player's custom data
		local plrData = player:FindFirstChild("plrData")
		if plrData then
			local lastNameObject = plrData:FindFirstChild("LastName")
			local firstNameObject = plrData:FindFirstChild("FirstName")
			local guild = plrData:FindFirstChild("Guild")
			local guildColor: StringValue
			local guildName: StringValue
			local guildRank: StringValue
			local isDeveloper = util.isDeveloper(player.UserId)

			local hexCodeForMessage
			local hexCodeForTag

			-- Adjust dev tag color based on special developer UserIds
			if isDeveloper then
				if player.UserId == 3842559869 then -- Special dev color for Giny
					hexCodeForTag = "#8B0000" -- Dark red
				elseif player.UserId == 1286142955 then -- Special dev color for Rynzite
					hexCodeForTag = "#401d5f" -- Dark purple
				else
					hexCodeForTag = "#00008B"
				end
			end

			if guild then
				guildColor = guild:FindFirstChild("GuildColor") -- (ex., '255, 0, 0')
				guildName = guild:FindFirstChild("GuildName")
				local guildMembers = guild:FindFirstChild("GuildMembers") -- Guild members and ranks

				-- Safely extract hex color from RGB value
				if guildColor then
					local r, g, b = guildColor.Value:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
					if r and g and b then
						hexCodeForMessage = string.format("#%02X%02X%02X", tonumber(r), tonumber(g), tonumber(b))
					end
				end

				-- Check if player's UserId is in the GuildMembers list and get their rank
				if guildMembers then
					local members = game:GetService("HttpService"):JSONDecode(guildMembers.Value)
					local playerRank = members[tostring(player.UserId)]  -- Use tostring because keys in JSON are strings
					if playerRank then
						guildRank = playerRank  -- Set the player's rank
					end
				end
			end

			-- Ensure both LastName and FirstName objects exist and are valid
			if lastNameObject and firstNameObject and 
				lastNameObject:IsA("StringValue") and firstNameObject:IsA("StringValue") then

				local lastName = lastNameObject.Value
				local firstName = firstNameObject.Value

				-- Create the dev tag with special color
				local devTag = ""
				if isDeveloper then
					if player.UserId == 3842559869 then -- Special dev color for Giny | 3842559869
						devTag = string.format("<b><font color='%s' face='Bangers'>[ B E S T  M O D E L E R ]</font></b>", hexCodeForTag)
					elseif player.UserId == 1286142955 then -- Special dev color for Rynzite | 1286142955
						devTag = string.format("<b><font color='%s' face='Bangers'>[ S Y S T E M  C R E A T O R ]</font></b>", hexCodeForTag)
					else
						devTag = string.format("<b><font color='%s' face='Bangers'>[ D E V ]</font></b>", hexCodeForTag)
					end
				end

				if messageText:sub(1, 1) == "/" then
					messageText = messageText:sub(2)
				end

				-- Update message's PrefixText with formatted name, rank, and dev tag
				if guildName then
					newMessage.Text = string.format("<font color='%s'>%s[%s - %s] [%s %s]: %s</font>", hexCodeForMessage or "#FFFFFF", devTag, guildName.Value, guildRank, lastName, firstName, messageText)
				else
					newMessage.Text = string.format("<font color='%s'>%s[%s %s]: %s</font>", hexCodeForMessage or "#FFFFFF", devTag, lastName, firstName, messageText)
				end
			end
		end
	end

	newMessage.Parent = ChatFrame
	newMessage.Visible = true
	table.insert(visibleMessages, newMessage)

	if #visibleMessages >= minMessagesToAutoScroll then
		ChatFrame.CanvasSize = UDim2.new(0, 0, 0, ChatFrame.UIListLayout.AbsoluteContentSize.Y)
		ChatFrame.CanvasPosition = Vector2.new(0, ChatFrame.UIListLayout.AbsoluteContentSize.Y - ChatFrame.AbsoluteSize.Y)
	end
end

local function sendMessage(message, privatePlayerName, isSystem)
	if message ~= "" then
		if not isSystem then
			if privatePlayerName then
				local privatePlayer = game:GetService("Players"):FindFirstChild(privatePlayerName) or nil
				if privatePlayer then
					game.ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Events").ClientEvent:FireServer(message, privatePlayer)
				end
			else
				game.ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Events").ClientEvent:FireServer(message)
			end
		else
			warn("s2")
			game.ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Events").ClientEvent:FireServer(message, nil, true)
		end
	end
end

game:GetService("UserInputService").InputEnded:Connect(function(input, isProcessed)
    if not isProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Slash then
			ChatSystem.Visible = true
			EnterChat:CaptureFocus()
        end
    end
end)

EnterChat.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local message = EnterChat.Text
		if message:sub(1, 1) == "/" then
			message = message:sub(2)
		end
		
		if message:sub(1, 1) == "!" then
			adminCmdEvent:FireServer(message)
			sendMessage(message)
		elseif message:sub(1, 7) == "--hide " and message:sub(8, 8) == "!" then
			message = message:sub(7)
			adminCmdEvent:FireServer(message)
		elseif message:sub(1, 5) == "--pm=" then -- Private message
			message = message:sub(5)
			
			-- strip player name from '--pm=' ex., if it finds something like '--pm=Rynzite' then it takes the word/name following the equal sign and assigns it to
			-- a variable
			local spaceIndex = message:find(" ")
			local playerName = message:sub(2, spaceIndex - 1)
			message = message:sub(spaceIndex + 1)
			
			sendMessage(message, playerName)
		elseif util.isDeveloper(Player.UserId) and message:sub(1, 5) == "--sm=" then
			message = message:sub(6)
			sendMessage(message, nil, true)
		elseif message == "--help" then
			createNewChatMessage("System", "You can use '--pm=PlayerName message' to send a")
			createNewChatMessage("System", "private message.")
			createNewChatMessage("System", "You can use '--hide !cmdName <params>' to hide a")
			createNewChatMessage("System", "command.")
		else
			sendMessage(message)
		end
		resetFade()
	end
end)

EnterChat.Focused:Connect(resetFade)
EnterChat.Changed:Connect(resetFade)

game.ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Events").ClientEvent.OnClientEvent:Connect(function(sender, message, isSystem)
	if not isSystem then
		createNewChatMessage(sender, message)
	else
		warn("s3")
		createNewChatMessage("System", message)
	end
end)

createNewChatMessage("System", "Use '--help' for a list of chat commands.")
spawn(fadeChat)
