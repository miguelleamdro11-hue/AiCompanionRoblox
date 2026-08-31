local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PANEL_WIDTH = 380
local PANEL_HEIGHT = 600
local OPEN_SIZE = 60

local FOLLOW_DISTANCE = 4
local FOLLOW_SPEED = 12
local STOP_DISTANCE = 2.5
local TURN_SPEED = 9
local TELEPORT_DISTANCE = 30

local FRIENDSHIP_SPAWN_DISTANCE = 18
local FRIENDSHIP_APPROACH_DISTANCE = 5

-- The NPC does NOT notice the player immediately.
local NOTICE_MIN_TIME = 8
local NOTICE_MAX_TIME = 24

-- How far a stranger can wander from its original area.
local STRANGER_WANDER_DISTANCE = 8

-- Strangers/acquaintances keep their own space. They may occasionally
-- come near the player, but only Friends are allowed to follow.
local STRANGER_SOCIAL_DISTANCE = 7
local ACQUAINTANCE_SOCIAL_DISTANCE = 5
local STRANGER_APPROACH_CHANCE = 0.30
local ACQUAINTANCE_APPROACH_CHANCE = 0.48
local SOCIAL_APPROACH_MIN_TIME = 10
local SOCIAL_APPROACH_MAX_TIME = 22
local SOCIAL_APPROACH_DURATION_MIN = 4
local SOCIAL_APPROACH_DURATION_MAX = 9

local WANDER_MIN_DISTANCE = 1
local WANDER_MIN_TIME = 2
local WANDER_MAX_TIME = 5

local DIALOGUE_MIN_TIME = 12
local DIALOGUE_MAX_TIME = 28

local QUIRK_MIN_TIME = 18
local QUIRK_MAX_TIME = 40

local DEFAULT_IDLE_ANIMATION = "rbxassetid://507766666"
local DEFAULT_WALK_ANIMATION = "rbxassetid://507777826"

local CLICK_SOUND = "rbxassetid://12221967"
local OPEN_SOUND = "rbxassetid://12222200"
local SUCCESS_SOUND = "rbxassetid://12222253"
local DELETE_SOUND = "rbxassetid://12222225"
local ERROR_SOUND = "rbxassetid://12222242"

------------------------------------------------------------
-- PERSONALITIES
------------------------------------------------------------

local PERSONALITY_PROFILES = {

	Friendly = {
		WanderChance = 0.28,
		WanderDistance = 1.8,
		WalkSpeed = 10,

		IdleAnimation = DEFAULT_IDLE_ANIMATION,
		WalkAnimation = DEFAULT_WALK_ANIMATION,
		QuirkAnimation = nil,

		Chats = {
			"Hey, {user}.",
			"Glad you're here.",
			"It's nice having someone around.",
			"How's your day going?",
			"I kinda like just hanging out here.",
			"You know, this isn't such a bad place.",
			"I'm glad I get to stick around with you.",
			"Hey. Just checking in.",
			"You doing alright?",
			"I was wondering when you'd come back.",
			"This is actually pretty nice.",
			"Thanks for letting me tag along."
		},

		AcquaintanceChats = {
			"Oh. Hey, {user}.",
			"I guess we're getting to know each other.",
			"Huh... I guess I'm starting to recognize you.",
			"Hey again.",
			"I don't mind seeing you around.",
			"We should probably hang out more."
		},

		FriendChats = {
			"Hey, {user}! Good to see you.",
			"I was hoping you'd show up.",
			"I really like hanging out with you.",
			"We're actually becoming pretty good friends.",
			"You know you can count on me.",
			"I'm glad we met.",
			"I feel like I can tell you things.",
			"This is always more fun when you're here."
		},

		BestFriendChats = {
			"You're my best friend, {user}.",
			"I don't think I'd want to do this with anyone else.",
			"You know me better than most people.",
			"I'm always sticking with you.",
			"We've come a long way.",
			"I'm really glad you're my best friend.",
			"Whatever happens, I'm here.",
			"You and me? We're a team."
		}
	},

	Funny = {
		WanderChance = 0.55,
		WanderDistance = 2.7,
		WalkSpeed = 12,

		IdleAnimation = DEFAULT_IDLE_ANIMATION,
		WalkAnimation = DEFAULT_WALK_ANIMATION,
		QuirkAnimation = "rbxassetid://105472825318565",

		Chats = {
			"Hey, {user}. I'm doing my best. Probably.",
			"Don't ask what I'm doing.",
			"I meant to do that.",
			"{user}, I have a very important question. Why am I like this?",
			"I've decided this is a good place to stand.",
			"Everything is under control. Mostly.",
			"I had a plan five seconds ago.",
			"Okay, that looked cooler in my head.",
			"Please pretend you didn't see that.",
			"I swear I'm being productive.",
			"Do you ever just... walk somewhere for no reason?",
			"I'm not lost. I'm exploring.",
			"That was absolutely intentional.",
			"I have no explanation for what just happened."
		},

		AcquaintanceChats = {
			"Oh. It's you again.",
			"Don't worry, I remember you. Probably.",
			"Look who decided to show up.",
			"We're acquaintances now. Fancy.",
			"Hey, {user}. Don't make this awkward.",
			"I guess you're okay."
		},

		FriendChats = {
			"HEY! My favorite walking disaster!",
			"{user}! Excellent. I was getting bored.",
			"We're friends now, apparently. Terrible decision.",
			"I've decided you're stuck with me.",
			"Don't worry, I'll only embarrass you sometimes.",
			"You're surprisingly tolerable.",
			"Friendship achievement unlocked."
		},

		BestFriendChats = {
			"BEST FRIEND DETECTED.",
			"{user}! My partner in questionable decisions!",
			"We've reached maximum friendship. Probably.",
			"You're legally required to put up with me now.",
			"Best friends forever. No take-backs.",
			"I trust you with my extremely important secrets.",
			"Look at us. Absolute legends."
		}
	},

	Curious = {
		WanderChance = 0.7,
		WanderDistance = 3.2,
		WalkSpeed = 11,

		IdleAnimation = DEFAULT_IDLE_ANIMATION,
		WalkAnimation = DEFAULT_WALK_ANIMATION,
		QuirkAnimation = nil,

		Chats = {
			"What do you think is over there?",
			"I wonder what's around that corner.",
			"Have you noticed anything strange?",
			"I kinda want to explore.",
			"Why do you think that works like that?",
			"There's probably something interesting nearby.",
			"Do you think we should go check that out?",
			"I keep noticing little things around here.",
			"I wonder how far we can go.",
			"Something about this place feels interesting.",
			"Wait... did you see that?",
			"I have so many questions."
		},

		AcquaintanceChats = {
			"I've been wondering about you.",
			"I think I'm starting to understand you.",
			"You're interesting.",
			"I keep noticing things about you.",
			"I wonder what you usually do around here.",
			"I think I'd like to know you better."
		},

		FriendChats = {
			"I feel like I can ask you anything.",
			"You've become one of my favorite people to explore with.",
			"I wonder how much more we'll discover together.",
			"I'm really glad I got curious enough to meet you.",
			"You make exploring more interesting.",
			"I trust you.",
			"I think we're pretty good friends."
		},

		BestFriendChats = {
			"I think I know you better than I expected.",
			"There's still so much to discover about you.",
			"I could explore this entire world with you.",
			"You're my favorite person to wonder about.",
			"We've learned a lot about each other.",
			"I don't think I'll ever get bored around you."
		}
	},

	Dominant = {
		WanderChance = 0.9,
		WanderDistance = 4,
		WalkSpeed = 16,

		IdleAnimation = "rbxassetid://132069965396465",
		WalkAnimation = "rbxassetid://84814915379579",
		QuirkAnimation = "rbxassetid://74073975404500",

		Chats = {
			"{user}, stay close.",
			"Come on. We're moving.",
			"Keep up.",
			"I'll decide where we're going.",
			"Stay with me.",
			"Don't wander too far.",
			"Right here. That's better.",
			"We're going this way.",
			"I've got it handled.",
			"Trust me.",
			"You're safer staying nearby.",
			"Let's keep moving."
		},

		AcquaintanceChats = {
			"You're starting to learn how I work.",
			"Stay nearby.",
			"I don't mind having you around.",
			"You're not as annoying as I expected.",
			"Keep up, {user}.",
			"I suppose we're getting along."
		},

		FriendChats = {
			"Good. You're one of mine now.",
			"I trust you. Don't make me regret it.",
			"Stay close. I've got your back.",
			"We make a good team.",
			"You're doing fine, {user}.",
			"I'll admit it. I like having you around.",
			"Nobody messes with my friends."
		},

		BestFriendChats = {
			"You're family at this point.",
			"I'd trust you with anything.",
			"Best friends. Don't get used to me saying that.",
			"You've earned my respect.",
			"I'm not leaving your side.",
			"If something happens, we're handling it together.",
			"You're one of the few people I'd follow anywhere."
		}
	},

	Shy = {
		WanderChance = 0.18,
		WanderDistance = 1.1,
		WalkSpeed = 8,

		IdleAnimation = "rbxassetid://73276069137252",
		WalkAnimation = "rbxassetid://106591492066105",
		QuirkAnimation = "rbxassetid://116263313772138",

		Chats = {
			"Um... hey, {user}.",
			"Don't look at me like that...",
			"I was just standing here.",
			"It's nice having you around.",
			"Uh... what are we doing?",
			"I don't really mind staying here.",
			"You're easy to be around.",
			"I was going to say something... never mind.",
			"Do you want to go somewhere?",
			"Sorry. I'm being quiet again.",
			"I like this spot.",
			"Thanks for staying with me."
		},

		AcquaintanceChats = {
			"Um... you're back.",
			"I was wondering if you'd come over.",
			"I think I'm getting used to you.",
			"You're... not so scary.",
			"I don't mind talking to you.",
			"I guess we're friends... kind of."
		},

		FriendChats = {
			"I really like spending time with you.",
			"I feel comfortable around you.",
			"Thanks for always coming back.",
			"I... think you're important to me.",
			"I don't get nervous around you as much anymore.",
			"I like being your friend.",
			"Can we stay together a little longer?"
		},

		BestFriendChats = {
			"I don't think I could imagine this without you.",
			"You're the person I feel safest around.",
			"I'm really happy you're my best friend.",
			"I trust you more than anyone.",
			"Please don't disappear on me.",
			"I'll always come find you.",
			"I'm glad I finally opened up."
		}
	},

	Serious = {
		WanderChance = 0.12,
		WanderDistance = 0.8,
		WalkSpeed = 9,

		IdleAnimation = DEFAULT_IDLE_ANIMATION,
		WalkAnimation = DEFAULT_WALK_ANIMATION,
		QuirkAnimation = nil,

		Chats = {
			"We should stay focused.",
			"Everything appears normal.",
			"Keep your attention here.",
			"I'm watching the area.",
			"Nothing unusual so far.",
			"We should probably stay together.",
			"Take your time.",
			"I've got an eye on things.",
			"There's no reason to rush.",
			"Everything seems under control.",
			"Let's stay alert.",
			"I'll keep watch."
		},

		AcquaintanceChats = {
			"I've started to recognize your habits.",
			"You're becoming familiar.",
			"I don't mind your company.",
			"We're getting to know each other.",
			"I've noticed you're reliable.",
			"I suppose I trust you more now."
		},

		FriendChats = {
			"I trust your judgment.",
			"You've proven yourself reliable.",
			"I'm glad you're here.",
			"We work well together.",
			"I consider you a friend.",
			"You've earned my confidence.",
			"I'll be there when you need me."
		},

		BestFriendChats = {
			"You're one of the few people I fully trust.",
			"I don't say this often, but you're important to me.",
			"I consider you family.",
			"I know you'll be there.",
			"You've earned my complete trust.",
			"I'll always keep watch for you."
		}
	},

	Brave = {
		WanderChance = 0.45,
		WanderDistance = 2.4,
		WalkSpeed = 13,

		IdleAnimation = DEFAULT_IDLE_ANIMATION,
		WalkAnimation = DEFAULT_WALK_ANIMATION,
		QuirkAnimation = nil,

		Chats = {
			"Nothing scares me.",
			"Let's go.",
			"I'll handle it.",
			"We can take on anything.",
			"Come on. What's the worst that could happen?",
			"I've got your back.",
			"Don't worry about it.",
			"We'll figure it out.",
			"Let's see what's ahead.",
			"I don't mind going first.",
			"Whatever happens, we'll deal with it.",
			"Stay close. I've got you."
		},

		AcquaintanceChats = {
			"You're tougher than I expected.",
			"I think we're getting along.",
			"Come on, let's go somewhere.",
			"I don't mind having you beside me.",
			"You're starting to earn my trust.",
			"I think you're alright."
		},

		FriendChats = {
			"I've got your back, always.",
			"You're one of my people now.",
			"We can handle anything together.",
			"I'd go into danger with you.",
			"You're a good friend.",
			"Nothing's getting past us.",
			"I trust you."
		},

		BestFriendChats = {
			"You and me against the world.",
			"I'd follow you anywhere.",
			"You're my closest friend.",
			"Whatever comes next, we'll handle it.",
			"I'd never leave you behind.",
			"We're unstoppable together."
		}
	},

	Sarcastic = {
		WanderChance = 0.5,
		WanderDistance = 2.2,
		WalkSpeed = 11,

		IdleAnimation = DEFAULT_IDLE_ANIMATION,
		WalkAnimation = DEFAULT_WALK_ANIMATION,
		QuirkAnimation = nil,

		Chats = {
			"Wow. What an exciting day.",
			"Yes, I'm standing here. Incredible.",
			"Brilliant plan.",
			"I totally wasn't bored.",
			"Sure. Let's do that.",
			"Fantastic. Exactly what I expected.",
			"Yeah, this seems completely normal.",
			"Nothing weird happening here at all.",
			"Great. Another adventure.",
			"I couldn't possibly be more impressed.",
			"Sure, {user}. That sounds like a plan.",
			"Absolutely. I'm thrilled."
		},

		AcquaintanceChats = {
			"Oh. You again.",
			"You're becoming suspiciously familiar.",
			"I suppose you're alright.",
			"Congratulations. I remember your name.",
			"I guess we can hang out.",
			"Don't get excited. I said you're alright."
		},

		FriendChats = {
			"Ugh. Fine. You're my friend.",
			"Don't make me admit that I like hanging out with you.",
			"You're surprisingly tolerable.",
			"I guess I'd notice if you disappeared.",
			"Don't get sentimental.",
			"You're alright, {user}.",
			"Fine. I trust you."
		},

		BestFriendChats = {
			"Don't tell anyone, but you're my favorite.",
			"Yeah, yeah. Best friends. Whatever.",
			"I suppose you're stuck with me.",
			"You're annoyingly important to me.",
			"I'd miss you. There, happy?",
			"Fine. You're family now.",
			"Don't expect me to get emotional about it."
		}
	},

	--------------------------------------------------------
	-- TSUNDERE
	--------------------------------------------------------
	-- Same animations as Dominant.
	--------------------------------------------------------

	Tsundere = {
		WanderChance = 0.72,
		WanderDistance = 3.5,
		WalkSpeed = 16,

		IdleAnimation = "rbxassetid://132069965396465",
		WalkAnimation = "rbxassetid://84814915379579",
		QuirkAnimation = "rbxassetid://74073975404500",

		Chats = {
			"Hmph. Don't think I noticed you.",
			"Why are you looking at me?",
			"I wasn't waiting for you.",
			"Whatever.",
			"Don't get the wrong idea.",
			"I just happened to be standing here.",
			"You're kind of annoying.",
			"Stop staring.",
			"I don't care if you're here.",
			"Do whatever you want.",
			"It's not like I was hoping you'd come back.",
			"Hmph."
		},

		AcquaintanceChats = {
			"Oh. It's you.",
			"I guess you're... okay.",
			"Don't misunderstand. I just remembered you.",
			"You're becoming a little too familiar.",
			"Why do you keep showing up?",
			"I don't mind you being here.",
			"Don't smile like that.",
			"Whatever. Stay if you want."
		},

		FriendChats = {
			"You're my friend. That's all.",
			"Don't get excited! I just like having you around.",
			"I wasn't waiting for you!",
			"You're... actually not terrible.",
			"I guess I trust you.",
			"Don't make me say it twice.",
			"I like hanging out with you, okay?!",
			"You're important. But don't let it go to your head.",
			"Come on. Stay close.",
			"I'd notice if you left. That's all."
		},

		BestFriendChats = {
			"You're my best friend. Don't make a big deal out of it.",
			"Obviously I was worried about you.",
			"I don't need anyone else when you're around.",
			"Don't you dare disappear on me.",
			"You're... really important to me.",
			"I'd choose you over everyone else.",
			"Just stay here, okay?",
			"I trust you completely. Happy now?",
			"I missed you. There. I said it.",
			"You're stuck with me forever."
		}
	}
,

	Enemy = {
		WanderChance = 0.68,
		WanderDistance = 4.5,
		WalkSpeed = 13,
		NoCrush = true,

		IdleAnimation = DEFAULT_IDLE_ANIMATION,
		WalkAnimation = DEFAULT_WALK_ANIMATION,
		QuirkAnimation = nil,

		Chats = {
			"Don't come any closer.",
			"I know you're there.",
			"Keep your distance.",
			"Seriously? You again?",
			"I don't like you hovering around me.",
			"Go bother somebody else.",
			"I'm not in the mood for you.",
			"Why are you still here?",
			"Don't mistake silence for friendship.",
			"You should probably leave me alone."
		},

		AcquaintanceChats = {
			"You're becoming a little too familiar.",
			"I remember you. Unfortunately.",
			"Don't read too much into me standing here.",
			"I can tolerate you. That's about it.",
			"You're still on thin ice.",
			"Why do you keep coming back?",
			"I suppose you're less annoying than before.",
			"Don't expect me to call us friends."
		},

		FriendChats = {
			"Fine. You're a friend. Don't make it weird.",
			"I've got your back. Probably.",
			"You're the one person I don't mind following.",
			"Don't get smug. I still hate everyone else.",
			"You're alright, {user}. That's high praise.",
			"I trust you. Don't waste it.",
			"Stay close. I said I trust you.",
			"Looks like we're stuck together now."
		},

		BestFriendChats = {
			"You're the exception. Don't get used to it.",
			"If anyone messes with you, they're dealing with me.",
			"I'd follow you anywhere. Quietly. Obviously.",
			"You're family now. Unfortunately for both of us.",
			"I trust you more than I trust almost anyone.",
			"You're the only person I don't mind seeing every day.",
			"Don't disappear. I actually notice when you're gone.",
			"Yeah, you're my best friend. Happy?"
		}
	}}

------------------------------------------------------------
-- RELATIONSHIP SYSTEM
------------------------------------------------------------

local RELATIONSHIP_STAGES = {
	{
		Name = "Stranger",
		Min = 0,
		Color = Color3.fromRGB(170, 174, 190)
	},

	{
		Name = "Acquaintance",
		Min = 20,
		Color = Color3.fromRGB(120, 190, 255)
	},

	{
		Name = "Friend",
		Min = 50,
		Color = Color3.fromRGB(110, 220, 150)
	},

	{
		Name = "Best Friend",
		Min = 85,
		Color = Color3.fromRGB(255, 205, 90)
	}
}

local function getRelationshipStage(value)
	local result = RELATIONSHIP_STAGES[1]

	for _, stage in ipairs(RELATIONSHIP_STAGES) do
		if value >= stage.Min then
			result = stage
		end
	end

	return result
end

------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------

local companion
local companionHumanoid
local companionRoot

local idleTrack
local walkTrack
local quirkTrack

local followConnection

local companionCreated = false
local savedAI

local selectedMode = "Mine"
local currentCharacter
local currentProfile

local wanderOffset = Vector3.zero
local wanderTimer = 0
local nextWanderTime = 3
local wandering = false
local doingQuirk = false

local dialogueTimer = 0
local nextDialogueTime = 18

local quirkTimer = 0
local nextQuirkTime = 30

local friendshipEnabled = false

-- Relationship value persists during the session.
local friendshipValue = 0

local friendshipBar
local friendshipFill
local friendshipLabel
local relationshipStatusLabel

local approachPhase = false
local firstMeetingPlayed = false

local socialApproachActive = false
local socialApproachTimer = 0
local nextSocialApproachTime = 0
local socialApproachDuration = 0

local strangerPhase = false
local noticeTimer = 0
local nextNoticeTime = 0
local hasNoticedPlayer = false
local strangerHomePosition = nil

local crushActive = false
local crushRollTimer = 0
local nextCrushRoll = 0

local friendList = {}
local selectedFriend

local random = Random.new()

------------------------------------------------------------
-- GUI HELPERS
------------------------------------------------------------

local function create(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties) do
		object[property] = value
	end

	object.Parent = parent

	return object
end

local function round(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object

	return corner
end

local function outline(object, transparency, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Transparency = transparency or 0
	stroke.Thickness = thickness or 1
	stroke.Parent = object

	return stroke
end

local function tween(object, duration, properties)
	local info = TweenInfo.new(
		duration,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out
	)

	local animation = TweenService:Create(
		object,
		info,
		properties
	)

	animation:Play()

	return animation
end

------------------------------------------------------------
-- SOUNDS
------------------------------------------------------------

local function makeSound(name, id, volume)
	local sound = Instance.new("Sound")

	sound.Name = name
	sound.SoundId = id
	sound.Volume = volume or 0.5

	sound.Parent = SoundService

	return sound
end

local clickSound = makeSound("AI_Click", CLICK_SOUND, 0.35)
local openSound = makeSound("AI_Open", OPEN_SOUND, 0.4)
local successSound = makeSound("AI_Success", SUCCESS_SOUND, 0.45)
local deleteSound = makeSound("AI_Delete", DELETE_SOUND, 0.4)
local errorSound = makeSound("AI_Error", ERROR_SOUND, 0.35)

local function play(sound)
	if sound then
		pcall(function()
			sound:Play()
		end)
	end
end

------------------------------------------------------------
-- MAIN GUI
------------------------------------------------------------

local gui = Instance.new("ScreenGui")

gui.Name = "AICompanionCreator"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

gui.Parent = playerGui

------------------------------------------------------------
-- OPEN BUTTON
------------------------------------------------------------

local openButton = create("TextButton", {
	Name = "OpenButton",
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -14, 1, -14),
	Size = UDim2.fromOffset(OPEN_SIZE, OPEN_SIZE),
	BackgroundColor3 = Color3.fromRGB(72, 105, 255),
	BorderSizePixel = 0,
	Text = "AI",
	TextSize = 17,
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.new(1, 1, 1),
	AutoButtonColor = false
}, gui)

round(openButton, 19)
outline(openButton, 0.7, 1)

------------------------------------------------------------
-- PANEL
------------------------------------------------------------

local panel = create("Frame", {
	Name = "CreatorPanel",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(PANEL_WIDTH, PANEL_HEIGHT),
	BackgroundColor3 = Color3.fromRGB(19, 20, 27),
	BorderSizePixel = 0,
	Visible = false
}, gui)

round(panel, 23)
outline(panel, 0.7, 1)

local panelScale = Instance.new("UIScale")
panelScale.Scale = 0.9
panelScale.Parent = panel

------------------------------------------------------------
-- HEADER
------------------------------------------------------------

local header = create("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 78),
	BackgroundColor3 = Color3.fromRGB(28, 30, 40),
	BorderSizePixel = 0
}, panel)

round(header, 23)

create("Frame", {
	Position = UDim2.new(0, 0, 1, -24),
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundColor3 = Color3.fromRGB(28, 30, 40),
	BorderSizePixel = 0
}, header)

create("TextLabel", {
	Position = UDim2.fromOffset(18, 10),
	Size = UDim2.new(1, -75, 0, 27),
	BackgroundTransparency = 1,
	Text = "AI COMPANION",
	TextColor3 = Color3.new(1, 1, 1),
	TextSize = 19,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left
}, header)

create("TextLabel", {
	Position = UDim2.fromOffset(19, 39),
	Size = UDim2.new(1, -75, 0, 21),
	BackgroundTransparency = 1,
	Text = "Build someone who actually feels alive.",
	TextColor3 = Color3.fromRGB(150, 154, 171),
	TextSize = 11,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, header)

local closeButton = create("TextButton", {
	Name = "Close",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -12, 0.5, 0),
	Size = UDim2.fromOffset(44, 44),
	BackgroundColor3 = Color3.fromRGB(45, 47, 59),
	BorderSizePixel = 0,
	Text = "×",
	TextSize = 24,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Color3.fromRGB(225, 226, 232),
	AutoButtonColor = false
}, header)

round(closeButton, 14)

------------------------------------------------------------
-- SCROLL
------------------------------------------------------------

local scroll = create("ScrollingFrame", {
	Name = "Content",
	Position = UDim2.fromOffset(10, 88),
	Size = UDim2.new(1, -20, 1, -165),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	ScrollBarImageTransparency = 0.5,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new(0, 0, 0, 0)
}, panel)

local padding = Instance.new("UIPadding")

padding.PaddingTop = UDim.new(0, 3)
padding.PaddingBottom = UDim.new(0, 20)
padding.PaddingLeft = UDim.new(0, 4)
padding.PaddingRight = UDim.new(0, 4)

padding.Parent = scroll

local layout = Instance.new("UIListLayout")

layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder

layout.Parent = scroll

local function section(text)
	return create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 21),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.fromRGB(181, 185, 201),
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left
	}, scroll)
end

local function makeBox(placeholder, height)
	local box = create("TextBox", {
		Size = UDim2.new(1, 0, 0, height or 52),
		BackgroundColor3 = Color3.fromRGB(34, 36, 48),
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = placeholder,
		PlaceholderColor3 = Color3.fromRGB(112, 116, 133),
		TextColor3 = Color3.fromRGB(240, 241, 246),
		TextSize = 15,
		Font = Enum.Font.Gotham,
		ClearTextOnFocus = false,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center
	}, scroll)

	round(box, 14)
	outline(box, 0.87, 1)

	local p = Instance.new("UIPadding")

	p.PaddingLeft = UDim.new(0, 13)
	p.PaddingRight = UDim.new(0, 13)
	p.PaddingTop = UDim.new(0, 7)
	p.PaddingBottom = UDim.new(0, 7)

	p.Parent = box

	return box
end

------------------------------------------------------------
-- CHARACTER
------------------------------------------------------------

section("CHARACTER")

local avatarCard = create("Frame", {
	Size = UDim2.new(1, 0, 0, 94),
	BackgroundColor3 = Color3.fromRGB(28, 30, 40),
	BorderSizePixel = 0
}, scroll)

round(avatarCard, 15)

local avatarIcon = create("ImageLabel", {
	Position = UDim2.fromOffset(9, 9),
	Size = UDim2.fromOffset(76, 76),
	BackgroundColor3 = Color3.fromRGB(42, 44, 56),
	BorderSizePixel = 0,
	Image = "rbxthumb://type=AvatarHeadShot&id="
		.. player.UserId
		.. "&w=150&h=150"
}, avatarCard)

round(avatarIcon, 14)

local avatarTitle = create("TextLabel", {
	Position = UDim2.fromOffset(97, 14),
	Size = UDim2.new(1, -108, 0, 22),
	BackgroundTransparency = 1,
	Text = "Your Avatar",
	TextColor3 = Color3.new(1, 1, 1),
	TextSize = 15,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left
}, avatarCard)

local avatarDescription = create("TextLabel", {
	Position = UDim2.fromOffset(97, 39),
	Size = UDim2.new(1, -108, 0, 40),
	BackgroundTransparency = 1,
	Text = "Your AI will use your full avatar.",
	TextColor3 = Color3.fromRGB(145, 149, 166),
	TextSize = 11,
	Font = Enum.Font.Gotham,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top
}, avatarCard)

local avatarModes = create("Frame", {
	Size = UDim2.new(1, 0, 0, 46),
	BackgroundTransparency = 1
}, scroll)

local modeLayout = Instance.new("UIGridLayout")

modeLayout.CellSize = UDim2.new(0.333, -5, 1, 0)
modeLayout.CellPadding = UDim2.fromOffset(7, 0)

modeLayout.Parent = avatarModes

local function makeMode(text)
	local button = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(39, 41, 53),
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = Color3.fromRGB(190, 193, 204),
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false
	}, avatarModes)

	round(button, 12)

	return button
end

local myAvatarButton = makeMode("MINE")
local userAvatarButton = makeMode("USER")
local friendAvatarButton = makeMode("FRIEND")

local function selectMode(mode)
	selectedMode = mode

	for _, button in ipairs(avatarModes:GetChildren()) do
		if button:IsA("TextButton") then
			button.BackgroundColor3 = Color3.fromRGB(39, 41, 53)
			button.TextColor3 = Color3.fromRGB(190, 193, 204)
		end
	end

	local selected

	if mode == "Mine" then
		selected = myAvatarButton
	elseif mode == "User" then
		selected = userAvatarButton
	elseif mode == "Friend" then
		selected = friendAvatarButton
	end

	if selected then
		selected.BackgroundColor3 = Color3.fromRGB(70, 103, 255)
		selected.TextColor3 = Color3.new(1, 1, 1)
	end
end

selectMode("Mine")

local usernameBox = makeBox(
	"Enter a Roblox username...",
	50
)

usernameBox.Visible = false

local friendPicker = create("TextButton", {
	Name = "FriendPicker",
	Size = UDim2.new(1, 0, 0, 50),
	BackgroundColor3 = Color3.fromRGB(34, 36, 48),
	BorderSizePixel = 0,
	Text = "Choose a friend...",
	TextColor3 = Color3.fromRGB(150, 154, 171),
	TextSize = 13,
	Font = Enum.Font.GothamMedium,
	AutoButtonColor = false,
	Visible = false
}, scroll)

round(friendPicker, 14)
outline(friendPicker, 0.87, 1)

local friendListFrame = create("ScrollingFrame", {
	Name = "FriendList",
	Size = UDim2.new(1, 0, 0, 150),
	BackgroundColor3 = Color3.fromRGB(27, 29, 39),
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	Visible = false,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new()
}, scroll)

round(friendListFrame, 14)

local friendListLayout = Instance.new("UIListLayout")

friendListLayout.Padding = UDim.new(0, 5)
friendListLayout.Parent = friendListFrame

local friendListPadding = Instance.new("UIPadding")

friendListPadding.PaddingTop = UDim.new(0, 6)
friendListPadding.PaddingBottom = UDim.new(0, 6)
friendListPadding.PaddingLeft = UDim.new(0, 6)
friendListPadding.PaddingRight = UDim.new(0, 6)

friendListPadding.Parent = friendListFrame

------------------------------------------------------------
-- NAME
------------------------------------------------------------

section("AI NAME")

local nameBox = makeBox(
	"What should your AI be called?",
	50
)

------------------------------------------------------------
-- PERSONALITY
------------------------------------------------------------

section("PERSONALITY")

local personalityBox = makeBox(
	"Describe how your AI behaves...",
	100
)

personalityBox.TextYAlignment =
	Enum.TextYAlignment.Top

------------------------------------------------------------
-- CALLS PLAYER
------------------------------------------------------------

section("WHAT SHOULD IT CALL YOU?")

local callsBox = makeBox(
	"Example: Captain",
	50
)

------------------------------------------------------------
-- FRIENDSHIP
------------------------------------------------------------

section("FRIENDSHIP MODE")

local friendshipFrame = create("Frame", {
	Size = UDim2.new(1, 0, 0, 52),
	BackgroundColor3 = Color3.fromRGB(34, 36, 48),
	BorderSizePixel = 0
}, scroll)

round(friendshipFrame, 14)
outline(friendshipFrame, 0.87, 1)

local friendshipTitle = create("TextLabel", {
	Position = UDim2.fromOffset(13, 6),
	Size = UDim2.new(1, -78, 0, 20),
	BackgroundTransparency = 1,
	Text = "Friendship Mode",
	TextColor3 = Color3.fromRGB(235, 236, 242),
	TextSize = 13,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left
}, friendshipFrame)

local friendshipDescription = create("TextLabel", {
	Position = UDim2.fromOffset(13, 26),
	Size = UDim2.new(1, -78, 0, 18),
	BackgroundTransparency = 1,
	Text = "Start distant and build friendship.",
	TextColor3 = Color3.fromRGB(135, 139, 155),
	TextSize = 9,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, friendshipFrame)

local friendshipToggle = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -11, 0.5, 0),
	Size = UDim2.fromOffset(48, 27),
	BackgroundColor3 = Color3.fromRGB(55, 57, 70),
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false
}, friendshipFrame)

round(friendshipToggle, 14)

local friendshipKnob = create("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 3, 0.5, 0),
	Size = UDim2.fromOffset(21, 21),
	BackgroundColor3 = Color3.fromRGB(220, 221, 228),
	BorderSizePixel = 0
}, friendshipToggle)

round(friendshipKnob, 11)

local function setFriendshipToggle(enabled)
	friendshipEnabled = enabled

	if enabled then
		friendshipToggle.BackgroundColor3 =
			Color3.fromRGB(70, 103, 255)

		tween(friendshipKnob, 0.15, {
			Position = UDim2.new(
				1,
				-24,
				0.5,
				0
			)
		})
	else
		friendshipToggle.BackgroundColor3 =
			Color3.fromRGB(55, 57, 70)

		tween(friendshipKnob, 0.15, {
			Position = UDim2.new(
				0,
				3,
				0.5,
				0
			)
		})
	end
end

setFriendshipToggle(false)

friendshipToggle.Activated:Connect(function()
	play(clickSound)

	setFriendshipToggle(
		not friendshipEnabled
	)
end)

------------------------------------------------------------
-- QUICK TRAITS
------------------------------------------------------------

section("QUICK TRAITS")

local traits = {
	"Friendly",
	"Funny",
	"Curious",
	"Dominant",
	"Shy",
	"Serious",
	"Brave",
	"Sarcastic",
	"Tsundere",
	"Enemy"
}

local traitsFrame = create("Frame", {
	Size = UDim2.new(1, 0, 0, 230),
	BackgroundTransparency = 1
}, scroll)

local traitGrid = Instance.new("UIGridLayout")

traitGrid.CellSize =
	UDim2.new(0.5, -5, 0, 39)

traitGrid.CellPadding =
	UDim2.fromOffset(8, 7)

traitGrid.Parent = traitsFrame

local selectedTraits = {}

for _, trait in ipairs(traits) do

	selectedTraits[trait] = false

	local button = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(36, 38, 49),
		BorderSizePixel = 0,
		Text = trait,
		TextColor3 = Color3.fromRGB(190, 193, 204),
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false
	}, traitsFrame)

	round(button, 11)

	button.Activated:Connect(function()

		play(clickSound)

		selectedTraits[trait] =
			not selectedTraits[trait]

		if selectedTraits[trait] then

			button.BackgroundColor3 =
				Color3.fromRGB(70, 103, 255)

			button.TextColor3 =
				Color3.new(1, 1, 1)

		else

			button.BackgroundColor3 =
				Color3.fromRGB(36, 38, 49)

			button.TextColor3 =
				Color3.fromRGB(190, 193, 204)
		end
	end)
end

------------------------------------------------------------
-- STATUS
------------------------------------------------------------

local status = create("TextLabel", {
	Position = UDim2.new(0, 15, 1, -108),
	Size = UDim2.new(1, -30, 0, 25),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Color3.fromRGB(151, 155, 171),
	TextSize = 11,
	Font = Enum.Font.Gotham,
	TextWrapped = true
}, panel)

------------------------------------------------------------
-- BUTTONS
------------------------------------------------------------

local createButton = create("TextButton", {
	Name = "Create",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -15),
	Size = UDim2.new(1, -30, 0, 56),
	BackgroundColor3 = Color3.fromRGB(70, 103, 255),
	BorderSizePixel = 0,
	Text = "CREATE AI",
	TextColor3 = Color3.new(1, 1, 1),
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	AutoButtonColor = false
}, panel)

round(createButton, 15)

local startOverButton = create("TextButton", {
	Name = "StartOver",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -15),
	Size = UDim2.new(1, -30, 0, 56),
	BackgroundColor3 = Color3.fromRGB(101, 48, 57),
	BorderSizePixel = 0,
	Text = "START OVER",
	TextColor3 = Color3.new(1, 1, 1),
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	Visible = false,
	AutoButtonColor = false
}, panel)

round(startOverButton, 15)

------------------------------------------------------------
-- ROBLOX USER HELPERS
------------------------------------------------------------

local function getUserId(username)

	local clean =
		username:gsub("^%s+", "")
			:gsub("%s+$", "")

	if clean == "" then
		return nil
	end

	local success, userId =
		pcall(function()
			return Players:GetUserIdFromNameAsync(clean)
		end)

	if success then
		return userId
	end

	return nil
end

------------------------------------------------------------
-- FRIEND LIST
------------------------------------------------------------

local function clearFriendList()

	for _, child in ipairs(
		friendListFrame:GetChildren()
	) do

		if child:IsA("TextButton")
			or child:IsA("TextLabel") then

			child:Destroy()
		end
	end
end

local function loadFriends()

	clearFriendList()

	friendList = {}
	selectedFriend = nil

	local success, pages =
		pcall(function()
			return Players:GetFriendsAsync(
				player.UserId
			)
		end)

	if not success or not pages then

		status.Text =
			"Could not load your friends."

		return false
	end

	local allFriends = {}

	repeat

		local pageSuccess, page =
			pcall(function()
				return pages:GetCurrentPage()
			end)

		if pageSuccess and page then

			for _, friend in ipairs(page) do
				table.insert(
					allFriends,
					friend
				)
			end
		end

		local hasMore = false

		pcall(function()
			hasMore =
				pages.IsFinished == false
		end)

		if hasMore then

			local advanceSuccess =
				pcall(function()
					pages:AdvanceToNextPageAsync()
				end)

			if not advanceSuccess then
				break
			end

		else
			break
		end

	until false

	friendList = allFriends

	if #friendList == 0 then

		create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 35),
			BackgroundTransparency = 1,
			Text = "You don't have any friends to choose from.",
			TextColor3 = Color3.fromRGB(145, 149, 166),
			TextSize = 11,
			Font = Enum.Font.Gotham
		}, friendListFrame)

		return true
	end

	for _, friend in ipairs(friendList) do

		local friendButton = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = Color3.fromRGB(39, 41, 53),
			BorderSizePixel = 0,
			Text = "  "
				.. tostring(
					friend.DisplayName
						or friend.Username
				),
			TextColor3 = Color3.fromRGB(230, 231, 237),
			TextSize = 12,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false
		}, friendListFrame)

		round(friendButton, 10)

		friendButton.Activated:Connect(function()

			selectedFriend = friend

			friendPicker.Text =
				"✓ "
				.. tostring(
					friend.DisplayName
						or friend.Username
				)

			friendPicker.TextColor3 =
				Color3.fromRGB(235, 236, 242)

			friendListFrame.Visible = false

			avatarTitle.Text =
				tostring(
					friend.DisplayName
						or friend.Username
				)

			avatarDescription.Text =
				"Friend selected."

			avatarIcon.Image =
				"rbxthumb://type=AvatarHeadShot&id="
				.. tostring(friend.Id)
				.. "&w=150&h=150"

			usernameBox.Text =
				tostring(
					friend.Username or ""
				)

			play(clickSound)
		end)
	end

	return true
end

friendPicker.Activated:Connect(function()

	play(clickSound)

	if friendListFrame.Visible then

		friendListFrame.Visible = false

	else

		friendListFrame.Visible = true

		if #friendList == 0 then
			loadFriends()
		end
	end
end)

------------------------------------------------------------
-- AVATAR PREVIEW
------------------------------------------------------------

local function updateAvatarPreview()

	if usernameBox.Text == "" then
		return
	end

	status.Text =
		"Loading avatar..."

	local userId =
		getUserId(usernameBox.Text)

	if not userId then

		status.Text =
			"Username not found."

		play(errorSound)

		return
	end

	avatarIcon.Image =
		"rbxthumb://type=AvatarHeadShot&id="
		.. userId
		.. "&w=150&h=150"

	avatarTitle.Text =
		usernameBox.Text

	if selectedMode == "Friend" then

		avatarDescription.Text =
			"Friendship will be checked when you create it."

	else

		avatarDescription.Text =
			"Avatar preview loaded."
	end

	status.Text = ""
end

usernameBox.FocusLost:Connect(
	updateAvatarPreview
)

------------------------------------------------------------
-- AVATAR MODE BUTTONS
------------------------------------------------------------

myAvatarButton.Activated:Connect(function()

	play(clickSound)

	selectMode("Mine")

	usernameBox.Visible = false
	friendPicker.Visible = false
	friendListFrame.Visible = false

	avatarTitle.Text =
		"Your Avatar"

	avatarDescription.Text =
		"Your AI will use your full avatar."

	avatarIcon.Image =
		"rbxthumb://type=AvatarHeadShot&id="
		.. player.UserId
		.. "&w=150&h=150"
end)

userAvatarButton.Activated:Connect(function()

	play(clickSound)

	selectMode("User")

	usernameBox.Visible = true
	friendPicker.Visible = false
	friendListFrame.Visible = false

	avatarTitle.Text =
		"User Avatar"

	avatarDescription.Text =
		"Enter any Roblox username."
end)

friendAvatarButton.Activated:Connect(function()

	play(clickSound)

	selectMode("Friend")

	usernameBox.Visible = false
	friendPicker.Visible = true
	friendListFrame.Visible = false

	avatarTitle.Text =
		"Friend Avatar"

	avatarDescription.Text =
		"Choose someone from your Roblox friends."

	status.Text =
		"Loading your friends..."

	task.spawn(function()

		if loadFriends() then
			status.Text = ""
		end
	end)
end)

------------------------------------------------------------
-- PERSONALITY DETECTION
------------------------------------------------------------

local function getPersonalityProfile(personality)

	local lower =
		string.lower(personality or "")

	local strongestProfile
	local strongestScore = 0

	for trait, profile in pairs(
		PERSONALITY_PROFILES
	) do

		local score = 0

		if string.find(
			lower,
			string.lower(trait),
			1,
			true
		) then

			score += 5
		end

		if score > strongestScore then

			strongestScore = score
			strongestProfile = profile
		end
	end

	if strongestProfile then
		return strongestProfile
	end

	return {
		WanderChance = 0.35,
		WanderDistance = 2,
		WalkSpeed = FOLLOW_SPEED,

		IdleAnimation =
			DEFAULT_IDLE_ANIMATION,

		WalkAnimation =
			DEFAULT_WALK_ANIMATION,

		QuirkAnimation = nil,

		Chats = {
			"Hey, {user}.",
			"What are we doing?",
			"Nice to see you.",
			"You doing alright?",
			"Feels good to hang out."
		},

		AcquaintanceChats = {
			"Hey again.",
			"Nice to see you.",
			"We're getting to know each other."
		},

		FriendChats = {
			"I'm glad we're friends.",
			"I like hanging out with you.",
			"You're a good friend."
		},

		BestFriendChats = {
			"Somehow, you became my best friend. I'm not complaining.",
			"I'm always here for you.",
			"I'm glad we met."
		}
	}
end

------------------------------------------------------------
-- ANIMATION
------------------------------------------------------------

local function stopTrack(track)

	if track then

		pcall(function()
			track:Stop(0.15)
		end)
	end
end

local function setupAnimations(
	humanoid,
	profile
)

	stopTrack(idleTrack)
	stopTrack(walkTrack)
	stopTrack(quirkTrack)

	if idleTrack then
		pcall(function()
			idleTrack:Destroy()
		end)
	end

	if walkTrack then
		pcall(function()
			walkTrack:Destroy()
		end)
	end

	if quirkTrack then
		pcall(function()
			quirkTrack:Destroy()
		end)
	end

	idleTrack = nil
	walkTrack = nil
	quirkTrack = nil

	local animator =
		humanoid:FindFirstChildOfClass(
			"Animator"
		)

	if not animator then

		animator = Instance.new(
			"Animator"
		)

		animator.Parent = humanoid
	end

	local function load(id, priority)

		if not id then
			return nil
		end

		local animation =
			Instance.new("Animation")

		animation.AnimationId = id

		local success, track =
			pcall(function()
				return animator:LoadAnimation(
					animation
				)
			end)

		animation:Destroy()

		if not success then
			return nil
		end

		track.Looped = true
		track.Priority = priority

		return track
	end

	idleTrack =
		load(
			profile.IdleAnimation
				or DEFAULT_IDLE_ANIMATION,
			Enum.AnimationPriority.Idle
		)

	walkTrack =
		load(
			profile.WalkAnimation
				or DEFAULT_WALK_ANIMATION,
			Enum.AnimationPriority.Movement
		)

	quirkTrack =
		load(
			profile.QuirkAnimation,
			Enum.AnimationPriority.Action
		)

	if idleTrack then
		idleTrack:Play(0.2)
	end
end

------------------------------------------------------------
-- RELATIONSHIP VISUAL
------------------------------------------------------------

local function createFriendshipMeter(model)

	local head =
		model:FindFirstChild("Head")

	if not head then
		return
	end

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"FriendshipMeter"

	billboard.Adornee =
		head

	billboard.Size =
		UDim2.fromOffset(190, 60)

	billboard.StudsOffset =
		Vector3.new(0, 4.2, 0)

	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 80
	billboard.Parent = model

	relationshipStatusLabel =
		Instance.new("TextLabel")

	relationshipStatusLabel.Size =
		UDim2.new(1, 0, 0, 18)

	relationshipStatusLabel.BackgroundTransparency = 1

	relationshipStatusLabel.Text =
		"Stranger"

	relationshipStatusLabel.TextColor3 =
		Color3.fromRGB(170, 174, 190)

	relationshipStatusLabel.TextStrokeTransparency =
		0.5

	relationshipStatusLabel.TextSize = 12
	relationshipStatusLabel.Font =
		Enum.Font.GothamBold

	relationshipStatusLabel.Parent =
		billboard

	friendshipLabel =
		Instance.new("TextLabel")

	friendshipLabel.Position =
		UDim2.new(0, 0, 0, 18)

	friendshipLabel.Size =
		UDim2.new(1, 0, 0, 15)

	friendshipLabel.BackgroundTransparency = 1

	friendshipLabel.Text =
		"Friendship 0%"

	friendshipLabel.TextColor3 =
		Color3.new(1, 1, 1)

	friendshipLabel.TextStrokeTransparency =
		0.5

	friendshipLabel.TextSize = 10

	friendshipLabel.Font =
		Enum.Font.GothamBold

	friendshipLabel.Parent =
		billboard

	friendshipBar =
		Instance.new("Frame")

	friendshipBar.Position =
		UDim2.new(0, 15, 0, 36)

	friendshipBar.Size =
		UDim2.new(1, -30, 0, 9)

	friendshipBar.BackgroundColor3 =
		Color3.fromRGB(45, 47, 59)

	friendshipBar.BorderSizePixel = 0
	friendshipBar.Parent = billboard

	round(friendshipBar, 5)

	friendshipFill =
		Instance.new("Frame")

	friendshipFill.Size =
		UDim2.new(0, 0, 1, 0)

	friendshipFill.BackgroundColor3 =
		Color3.fromRGB(90, 150, 255)

	friendshipFill.BorderSizePixel = 0

	friendshipFill.Parent =
		friendshipBar

	round(friendshipFill, 5)
end

------------------------------------------------------------
-- UPDATE RELATIONSHIP VISUAL
------------------------------------------------------------

local function updateFriendshipMeter()

	if not friendshipEnabled then
		return
	end

	friendshipValue =
		math.clamp(
			friendshipValue,
			0,
			100
		)

	local stage =
		getRelationshipStage(
			friendshipValue
		)

	local displayName =
		stage.Name

	if crushActive then
		displayName =
			displayName
			.. "  ♥"
	end

	if friendshipFill then

		tween(friendshipFill, 0.35, {
			Size =
				UDim2.new(
					friendshipValue / 100,
					0,
					1,
					0
				)
		})

		friendshipFill.BackgroundColor3 =
			stage.Color
	end

	if friendshipLabel then

		friendshipLabel.Text =
			"Friendship "
			.. math.floor(friendshipValue)
			.. "%"
	end

	if relationshipStatusLabel then

		relationshipStatusLabel.Text =
			displayName

		relationshipStatusLabel.TextColor3 =
			crushActive
			and Color3.fromRGB(255, 130, 170)
			or stage.Color
	end
end

------------------------------------------------------------
-- NAME TAG
------------------------------------------------------------

local function createNameTag(model, aiName)

	local head =
		model:FindFirstChild("Head")

	if not head then
		return
	end

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"AINameTag"

	billboard.Adornee =
		head

	billboard.Size =
		UDim2.fromOffset(180, 45)

	billboard.StudsOffset =
		Vector3.new(0, 2.8, 0)

	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 80
	billboard.Parent = model

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.fromScale(1, 1)

	label.BackgroundTransparency = 1

	label.Text =
		aiName

	label.TextColor3 =
		Color3.new(1, 1, 1)

	label.TextStrokeTransparency =
		0.5

	label.TextSize = 14

	label.Font =
		Enum.Font.GothamBold

	label.Parent = billboard
end

------------------------------------------------------------
-- PREPARE MODEL
------------------------------------------------------------

local function prepareCompanion(model)

	for _, object in ipairs(
		model:GetDescendants()
	) do

		if object:IsA("BasePart") then

			object.CanCollide = false
			object.CanTouch = false
			object.CanQuery = false
			object.Massless = true

		elseif object:IsA("Script")
			or object:IsA("LocalScript") then

			object:Destroy()
		end
	end
end

------------------------------------------------------------
-- SPEECH
------------------------------------------------------------

local function say(text)

	if not companion then
		return
	end

	local head =
		companion:FindFirstChild("Head")

	if not head then
		head = companionRoot
	end

	if not head then
		return
	end

	local finalText =
		string.gsub(
			text,
			"{user}",
			callsBox.Text ~= ""
				and callsBox.Text
				or player.Name
		)

	pcall(function()

		TextChatService:DisplayBubble(
			head,
			finalText
		)
	end)
end

------------------------------------------------------------
-- GET CHAT FOR RELATIONSHIP
------------------------------------------------------------

local function getRelationshipChats()

	if not currentProfile then
		return {}
	end

	local stage =
		getRelationshipStage(
			friendshipValue
		)

	if stage.Name == "Best Friend"
		and currentProfile.BestFriendChats then

		return currentProfile.BestFriendChats

	elseif stage.Name == "Friend"
		and currentProfile.FriendChats then

		return currentProfile.FriendChats

	elseif stage.Name == "Acquaintance"
		and currentProfile.AcquaintanceChats then

		return currentProfile.AcquaintanceChats

	end

	return currentProfile.Chats
end

------------------------------------------------------------
-- RELATIONSHIP CHAT
------------------------------------------------------------

local function randomChat()

	if not currentProfile then
		return
	end

	local chats =
		getRelationshipChats()

	if not chats
		or #chats == 0 then

		return
	end

	local text =
		chats[
			random:NextInteger(
				1,
				#chats
			)
		]

	say(text)

	--------------------------------------------------------
	-- FRIENDSHIP GAIN
	--------------------------------------------------------

	if friendshipEnabled
		and hasNoticedPlayer then

		local stage =
			getRelationshipStage(
				friendshipValue
			)

		local gain

		if stage.Name == "Stranger" then

			gain =
				random:NextNumber(
					0.25,
					0.6
				)

		elseif stage.Name == "Acquaintance" then

			gain =
				random:NextNumber(
					0.35,
					0.8
				)

		elseif stage.Name == "Friend" then

			gain =
				random:NextNumber(
					0.25,
					0.6
				)

		else

			gain =
				random:NextNumber(
					0.1,
					0.35
				)
		end

		friendshipValue += gain

		updateFriendshipMeter()
	end
end

------------------------------------------------------------
-- RELATIONSHIP MILESTONES
------------------------------------------------------------

local lastRelationshipStage =
	"Stranger"

local function checkRelationshipMilestone()

	if not friendshipEnabled then
		return
	end

	local stage =
		getRelationshipStage(
			friendshipValue
		)

	if stage.Name ~= lastRelationshipStage then

		lastRelationshipStage =
			stage.Name

		if stage.Name == "Acquaintance" then

			say(
				"You're starting to feel familiar."
			)

		elseif stage.Name == "Friend" then

			say(
				"You know what? I actually like having you around."
			)

		elseif stage.Name == "Best Friend" then

			say(
				"You're my best friend."
			)
		end

		updateFriendshipMeter()
	end
end

------------------------------------------------------------
-- CRUSH SYSTEM
------------------------------------------------------------

local function checkForCrush(deltaTime)

	if not friendshipEnabled
		or crushActive
		or (currentProfile and currentProfile.NoCrush)
		or friendshipValue < 60
		or not hasNoticedPlayer then

		return
	end

	crushRollTimer += deltaTime

	if crushRollTimer <
		nextCrushRoll then

		return
	end

	crushRollTimer = 0

	nextCrushRoll =
		random:NextNumber(
			35,
			75
		)

	--------------------------------------------------------
	-- Small chance each roll.
	-- Higher friendship = higher chance.
	--------------------------------------------------------

	local chance =
		0.025
		+ ((friendshipValue - 60) / 40)
			* 0.10

	if random:NextNumber() <= chance then

		crushActive = true

		updateFriendshipMeter()

		----------------------------------------------------
		-- Personality-dependent crush reactions.
		----------------------------------------------------

		local crushLines = {

			"You know... I really like being around you.",

			"Why do I get so happy when you show up?",

			"I think I might like you... more than I should.",

			"Don't make this weird, okay?",

			"I've been thinking about you a lot lately.",

			"You're kind of important to me."
		}

		if string.find(
			string.lower(
				personalityBox.Text
			),
			"tsundere",
			1,
			true
		) then

			crushLines = {

				"I-I don't have a crush on you!",
				"Don't look at me like that!",
				"I just... like being around you, okay?!",
				"You're making my heart act weird.",
				"Stop making me nervous!",
				"It's not like I like you or anything!"
			}
		end

		say(
			crushLines[
				random:NextInteger(
					1,
					#crushLines
				)
			]
		)
	end
end

------------------------------------------------------------
-- FIRST MEETING
------------------------------------------------------------

local function playFirstMeeting()

	if firstMeetingPlayed then
		return
	end

	firstMeetingPlayed = true

	local meetingChats = {
		"Hey... have we actually met before?",
		"You look familiar. I can't place it.",
		"Wait... do I know you from somewhere?",
		"I swear I've seen you around here.",
		"Okay, you seem familiar somehow.",
		"Maybe we've crossed paths before."
	}

	say(
		meetingChats[
			random:NextInteger(
				1,
				#meetingChats
			)
		]
	)

	friendshipValue +=
		random:NextNumber(
			1,
			2
		)

	updateFriendshipMeter()
end

------------------------------------------------------------
-- WANDER
------------------------------------------------------------

local function chooseWander()

	if not companionRoot
		or not currentCharacter then

		return
	end

	local characterRoot =
		currentCharacter:
			FindFirstChild(
				"HumanoidRootPart"
			)

	if not characterRoot
		or not currentProfile then

		return
	end

	if random:NextNumber()
		> (
			currentProfile.WanderChance
			or 0.35
		) then

		wanderOffset =
			Vector3.zero

		wandering = false

		return
	end

	local maxDistance =
		math.max(
			WANDER_MIN_DISTANCE,
			currentProfile.WanderDistance
				or 2
		)

	local distance =
		random:NextNumber(
			WANDER_MIN_DISTANCE,
			maxDistance
		)

	local angle =
		random:NextNumber(
			0,
			math.pi * 2
		)

	local x =
		math.cos(angle)
			* distance

	local z =
		math.sin(angle)
			* distance

	wanderOffset =
		Vector3.new(
			x,
			0,
			z
		)

	wandering = true

	stopTrack(quirkTrack)

	wanderTimer = 0

	nextWanderTime =
		random:NextNumber(
			WANDER_MIN_TIME,
			WANDER_MAX_TIME
		)
end

------------------------------------------------------------
-- STRANGER WANDER
------------------------------------------------------------

local function chooseStrangerWander()

	if not companionRoot
		or not strangerHomePosition then

		return
	end

	local distance =
		random:NextNumber(
			2,
			STRANGER_WANDER_DISTANCE
		)

	local angle =
		random:NextNumber(
			0,
			math.pi * 2
		)

	local offset =
		Vector3.new(
			math.cos(angle) * distance,
			0,
			math.sin(angle) * distance
		)

	wanderOffset =
		strangerHomePosition
		+ offset
		- companionRoot.Position

	wanderOffset =
		Vector3.new(
			wanderOffset.X,
			0,
			wanderOffset.Z
		)

	wandering = true

	wanderTimer = 0

	nextWanderTime =
		random:NextNumber(
			2.5,
			6
		)
end

------------------------------------------------------------
-- RELATIONSHIP-AWARE SOCIAL APPROACH
------------------------------------------------------------

local function getMovementRelationshipStage()
	if not friendshipEnabled then
		return "Friend"
	end

	return getRelationshipStage(friendshipValue).Name
end

local function beginSocialApproach()
	if not companionRoot or not player.Character then
		return false
	end

	local playerRoot =
		player.Character:FindFirstChild("HumanoidRootPart")

	if not playerRoot then
		return false
	end

	local stageName = getMovementRelationshipStage()

	if stageName == "Friend"
		or stageName == "Best Friend" then
		return false
	end

	local chance =
		stageName == "Acquaintance"
		and ACQUAINTANCE_APPROACH_CHANCE
		or STRANGER_APPROACH_CHANCE

	if random:NextNumber() > chance then
		return false
	end

	socialApproachActive = true
	socialApproachTimer = 0
	socialApproachDuration =
		random:NextNumber(
			SOCIAL_APPROACH_DURATION_MIN,
			SOCIAL_APPROACH_DURATION_MAX
		)

	wanderOffset = Vector3.zero
	wandering = false
	doingQuirk = false

	return true
end

local function endSocialApproach()
	socialApproachActive = false
	socialApproachTimer = 0
	nextSocialApproachTime =
		random:NextNumber(
			SOCIAL_APPROACH_MIN_TIME,
			SOCIAL_APPROACH_MAX_TIME
		)

	wanderOffset = Vector3.zero
	wandering = false
	wanderTimer = 0
	nextWanderTime =
		random:NextNumber(2, 5)
end

------------------------------------------------------------
-- IDLE ACTION
------------------------------------------------------------

local function chooseIdleAction()

	if not companionRoot
		or not currentProfile then

		return
	end

	wanderOffset =
		Vector3.zero

	wandering = false
	wanderTimer = 0

	local canQuirk =
		quirkTrack ~= nil

	if canQuirk
		and random:NextNumber() < 0.28 then

		doingQuirk = true

		stopTrack(idleTrack)

		if quirkTrack
			and not quirkTrack.IsPlaying then

			quirkTrack:Play(0.2)
		end

		if random:NextNumber() < 0.35 then
			randomChat()
		end

		quirkTimer = 0

		nextQuirkTime =
			random:NextNumber(
				QUIRK_MIN_TIME,
				QUIRK_MAX_TIME
			)

		return
	end

	doingQuirk = false

	chooseWander()
end

------------------------------------------------------------
-- MOVEMENT
------------------------------------------------------------

local function moveCompanionTowards(
	currentPosition,
	targetPosition,
	speed,
	deltaTime
)

	if not companion then
		return currentPosition, 0
	end

	local offset =
		targetPosition
		- currentPosition

	local distance =
		offset.Magnitude

	if distance < 0.001 then
		return currentPosition, distance
	end

	local direction =
		offset.Unit

	local step =
		math.min(
			distance,
			speed * deltaTime
		)

	local newPosition =
		currentPosition
		+ direction * step

	local currentCFrame =
		companion:GetPivot()

	local currentLook =
		Vector3.new(
			currentCFrame.LookVector.X,
			0,
			currentCFrame.LookVector.Z
		)

	local targetLook =
		Vector3.new(
			direction.X,
			0,
			direction.Z
		)

	if targetLook.Magnitude < 0.001 then
		targetLook = currentLook
	end

	if currentLook.Magnitude < 0.001 then
		currentLook = targetLook
	else
		currentLook =
			currentLook.Unit
	end

	if targetLook.Magnitude < 0.001 then
		targetLook =
			Vector3.new(
				0,
				0,
				-1
			)
	else
		targetLook =
			targetLook.Unit
	end

	local lookAlpha =
		math.clamp(
			TURN_SPEED * deltaTime,
			0,
			1
		)

	local newLook =
		currentLook:Lerp(
			targetLook,
			lookAlpha
		)

	if newLook.Magnitude < 0.001 then
		newLook = targetLook
	else
		newLook =
			newLook.Unit
	end

	companion:PivotTo(
		CFrame.lookAt(
			newPosition,
			newPosition + newLook
		)
	)

	return newPosition, distance
end

------------------------------------------------------------
-- CHECK IF NPC CAN SEE PLAYER
------------------------------------------------------------

local function canSeePlayer(playerRoot)

	if not companionRoot
		or not playerRoot then

		return false
	end

	local origin =
		companionRoot.Position
		+ Vector3.new(0, 2, 0)

	local destination =
		playerRoot.Position
		+ Vector3.new(0, 2, 0)

	local direction =
		destination - origin

	local distance =
		direction.Magnitude

	if distance > 45 then
		return false
	end

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances = {
		companion,
		currentCharacter
	}

	local result =
		workspace:Raycast(
			origin,
			direction,
			params
		)

	return result == nil
end

------------------------------------------------------------
-- NPC NOTICES PLAYER
------------------------------------------------------------

local function noticePlayer()

	if hasNoticedPlayer then
		return
	end

	hasNoticedPlayer = true
	strangerPhase = false
	approachPhase = false
	socialApproachActive = false

	-- Being noticed is not the same as becoming attached.
	-- A stranger only comes over occasionally.
	if random:NextNumber() <= STRANGER_APPROACH_CHANCE then
		approachPhase = true
	end

	wanderOffset =
		Vector3.zero

	wandering = false
	doingQuirk = false

	stopTrack(quirkTrack)

	if idleTrack
		and not idleTrack.IsPlaying then

		idleTrack:Play(0.2)
	end

	--------------------------------------------------------
	-- Notice lines happen BEFORE approaching.
	--------------------------------------------------------

	local noticeLines = {
		"Wait... is that you?",
		"Oh. Hey.",
		"Huh. Didn't see you there.",
		"Hey... what are you doing?",
		"Oh, you're here.",
		"Didn't expect to see you.",
		"Hold on... I know you.",
		"Hey. You again."
	}

	say(
		noticeLines[
			random:NextInteger(
				1,
				#noticeLines
			)
		]
	)

	--------------------------------------------------------
	-- Short pause before approaching.
	--------------------------------------------------------

	task.delay(
		random:NextNumber(1.2, 2.8),
		function()

			if not companion
				or not companion.Parent then

				return
			end

			if not approachPhase then
				return
			end

			say(
				"Um... hi."
			)
		end
	)
end

------------------------------------------------------------
-- START FOLLOWING
------------------------------------------------------------

local function startFollowing()

	if followConnection then

		followConnection:Disconnect()

		followConnection = nil
	end

	wanderOffset =
		Vector3.zero

	wanderTimer = 0

	nextWanderTime =
		random:NextNumber(
			2,
			5
		)

\twandering = false
\tdoingQuirk = false
\tsocialApproachActive = false
\tsocialApproachTimer = 0
\tnextSocialApproachTime =
\t\trandom:NextNumber(
\t\t\tSOCIAL_APPROACH_MIN_TIME,
\t\t\tSOCIAL_APPROACH_MAX_TIME
\t\t)
\tsocialApproachDuration = 0

\tdialogueTimer = 0

	nextDialogueTime =
		random:NextNumber(
			DIALOGUE_MIN_TIME,
			DIALOGUE_MAX_TIME
		)

	quirkTimer = 0

	nextQuirkTime =
		random:NextNumber(
			QUIRK_MIN_TIME,
			QUIRK_MAX_TIME
		)

	crushRollTimer = 0

	nextCrushRoll =
		random:NextNumber(
			35,
			75
		)

	followConnection =
		RunService.RenderStepped:Connect(
			function(deltaTime)

				if not companion
					or not companion.Parent
					or not companionRoot then

					return
				end

				local character =
					player.Character

				if not character then
					return
				end

				currentCharacter =
					character

				local playerRoot =
					character:
						FindFirstChild(
							"HumanoidRootPart"
						)

				if not playerRoot then
					return
				end

				local profile =
					currentProfile
					or {
						WanderDistance = 2,
						WalkSpeed =
							FOLLOW_SPEED
					}

				local currentPosition =
					companionRoot.Position

				local speed =
					profile.WalkSpeed
					or FOLLOW_SPEED

				dialogueTimer +=
					deltaTime

				quirkTimer +=
					deltaTime

				------------------------------------------------
				-- STRANGER MODE
				------------------------------------------------

				if friendshipEnabled
					and not hasNoticedPlayer then

					noticeTimer +=
						deltaTime

					------------------------------------------------
					-- Wander independently.
					------------------------------------------------

					wanderTimer +=
						deltaTime

					if wanderTimer >=
						nextWanderTime then

						chooseStrangerWander()
					end

					local strangerTarget =
						strangerHomePosition
						or currentPosition

					local desiredPosition =
						strangerTarget
						+ wanderOffset

					desiredPosition =
						Vector3.new(
							desiredPosition.X,
							currentPosition.Y,
							desiredPosition.Z
						)

					local offset =
						desiredPosition
						- currentPosition

					local distance =
						offset.Magnitude

					if distance > 1.3 then

						moveCompanionTowards(
							currentPosition,
							desiredPosition,
							speed,
							deltaTime
						)

						if walkTrack
							and not walkTrack.IsPlaying then

							stopTrack(idleTrack)
							stopTrack(quirkTrack)

							walkTrack:Play(0.15)
						end

					else

						if walkTrack
							and walkTrack.IsPlaying then

							walkTrack:Stop(0.2)
						end

						if idleTrack
							and not idleTrack.IsPlaying then

							idleTrack:Play(0.2)
						end
					end

					------------------------------------------------
					-- The NPC has to wait before even considering
					-- noticing the player.
					------------------------------------------------

					if noticeTimer >=
						nextNoticeTime then

						local visible =
							canSeePlayer(
								playerRoot
							)

						local closeEnough =
							(
								playerRoot.Position
								- companionRoot.Position
							).Magnitude
							<= 35

						if visible
							and closeEnough then

							noticePlayer()

						else

							noticeTimer = 0

							nextNoticeTime =
								random:NextNumber(
									5,
									14
								)
						end
					end

					return
				end

				------------------------------------------------
				-- RELATIONSHIP DIALOGUE
				------------------------------------------------

				if dialogueTimer >=
					nextDialogueTime
					and not approachPhase
					and not doingQuirk then

					if random:NextNumber()
						< 0.72 then

						randomChat()
					end

					dialogueTimer = 0

					local stage =
						getRelationshipStage(
							friendshipValue
						)

					------------------------------------------------
					-- Higher relationship = more talking.
					------------------------------------------------

					if stage.Name ==
						"Acquaintance" then

						nextDialogueTime =
							random:NextNumber(
								9,
								20
							)

					elseif stage.Name ==
						"Friend" then

						nextDialogueTime =
							random:NextNumber(
								7,
								16
							)

					elseif stage.Name ==
						"Best Friend" then

						nextDialogueTime =
							random:NextNumber(
								5,
								12
							)

					else

						nextDialogueTime =
							random:NextNumber(
								DIALOGUE_MIN_TIME,
								DIALOGUE_MAX_TIME
							)
					end
				end

				------------------------------------------------
				-- CRUSH
				------------------------------------------------

				checkForCrush(deltaTime)

				------------------------------------------------
				-- MILESTONES
				------------------------------------------------

				checkRelationshipMilestone()

				------------------------------------------------
				-- APPROACHING PLAYER
				------------------------------------------------

				if approachPhase then

					local targetPosition =
						playerRoot.Position
						+ playerRoot.CFrame.RightVector
							* FOLLOW_DISTANCE

					targetPosition =
						Vector3.new(
							targetPosition.X,
							currentPosition.Y,
							targetPosition.Z
						)

					local approachOffset =
						targetPosition
						- currentPosition

					local approachDistance =
						approachOffset.Magnitude

					if approachDistance <=
						FRIENDSHIP_APPROACH_DISTANCE then

						approachPhase = false

						playFirstMeeting()

						wanderTimer = 0

						nextWanderTime = 3

						wandering = false
						doingQuirk = false

						if walkTrack
							and walkTrack.IsPlaying then

							walkTrack:Stop(0.2)
						end

						if idleTrack
							and not idleTrack.IsPlaying then

							idleTrack:Play(0.2)
						end

					else

						moveCompanionTowards(
							currentPosition,
							targetPosition,
							speed,
							deltaTime
						)

						if walkTrack
							and not walkTrack.IsPlaying then

							stopTrack(idleTrack)
							stopTrack(quirkTrack)

							walkTrack:Play(0.15)
						end

						return
					end
				end

				------------------------------------------------
				-- QUIRK
				------------------------------------------------

				if quirkTimer >=
					nextQuirkTime
					and not doingQuirk
					and not approachPhase then

					if quirkTrack
						and random:NextNumber()
							< 0.45 then

						doingQuirk = true

						stopTrack(idleTrack)

						if quirkTrack
							and not quirkTrack.IsPlaying then

							quirkTrack:Play(0.2)
						end

						quirkTimer = 0

						nextQuirkTime =
							random:NextNumber(
								QUIRK_MIN_TIME,
								QUIRK_MAX_TIME
							)

					else

						quirkTimer = 0

						nextQuirkTime =
							random:NextNumber(
								QUIRK_MIN_TIME,
								QUIRK_MAX_TIME
							)
					end
				end

				------------------------------------------------
				-- DOING QUIRK
				------------------------------------------------

				if doingQuirk then

					local followTarget =
						playerRoot.Position
						+ playerRoot.CFrame.RightVector
							* FOLLOW_DISTANCE

					local distance =
						(
							followTarget
							- currentPosition
						).Magnitude

					if distance >
						STOP_DISTANCE + 1.5 then

						doingQuirk = false

						stopTrack(quirkTrack)

						if idleTrack
							and not idleTrack.IsPlaying then

							idleTrack:Play(0.2)
						end

					else

						wanderTimer +=
							deltaTime

						if wanderTimer >=
							random:NextNumber(
								3,
								7
							) then

							doingQuirk = false

							stopTrack(
								quirkTrack
							)

							if idleTrack
								and not idleTrack.IsPlaying then

								idleTrack:Play(0.2)
							end

							wanderTimer = 0

							nextWanderTime =
								random:NextNumber(
									WANDER_MIN_TIME,
									WANDER_MAX_TIME
								)
						end

						return
					end
				end

				------------------------------------------------
				-- RELATIONSHIP-AWARE MOVEMENT
				--
				-- Stranger / Acquaintance wander independently.
				-- They may occasionally come near the player.
				-- Friend / Best Friend are allowed to follow.
				------------------------------------------------

				local relationshipStage =
					getMovementRelationshipStage()

				if friendshipEnabled
					and (
						relationshipStage == "Stranger"
						or relationshipStage == "Acquaintance"
					) then

					socialApproachTimer += deltaTime

					if not socialApproachActive
						and socialApproachTimer >= nextSocialApproachTime then

						beginSocialApproach()
						socialApproachTimer = 0
					end

					if socialApproachActive then
						socialApproachTimer += deltaTime

						local socialDistance =
							relationshipStage == "Acquaintance"
							and ACQUAINTANCE_SOCIAL_DISTANCE
							or STRANGER_SOCIAL_DISTANCE

						local socialTarget =
							playerRoot.Position
							+ playerRoot.CFrame.RightVector
							* socialDistance

						socialTarget = Vector3.new(
							socialTarget.X,
							currentPosition.Y,
							socialTarget.Z
						)

						local socialOffset =
							socialTarget - currentPosition

						if socialApproachTimer >= socialApproachDuration
							or socialOffset.Magnitude <= 1.5 then

							if not firstMeetingPlayed then
								playFirstMeeting()
							end

							endSocialApproach()

						else
							moveCompanionTowards(
								currentPosition,
								socialTarget,
								speed,
								deltaTime
							)

							if walkTrack
								and not walkTrack.IsPlaying then

								stopTrack(idleTrack)
								stopTrack(quirkTrack)
								walkTrack:Play(0.15)
							end

							return
						end
					end

					wanderTimer += deltaTime

					if wanderTimer >= nextWanderTime then
						chooseIdleAction()
					end

					local home =
						strangerHomePosition
						or currentPosition

					local independentTarget =
						home + wanderOffset

					independentTarget = Vector3.new(
						independentTarget.X,
						currentPosition.Y,
						independentTarget.Z
					)

					local independentOffset =
						independentTarget - currentPosition

					if independentOffset.Magnitude > 1.3 then
						moveCompanionTowards(
							currentPosition,
							independentTarget,
							speed,
							deltaTime
						)

						if walkTrack
							and not walkTrack.IsPlaying then

							stopTrack(idleTrack)
							stopTrack(quirkTrack)
							walkTrack:Play(0.15)
						end
					else
						if walkTrack
							and walkTrack.IsPlaying then
							walkTrack:Stop(0.2)
						end

						if not doingQuirk
							and idleTrack
							and not idleTrack.IsPlaying then
							idleTrack:Play(0.2)
						end
					end

					return
				end

				------------------------------------------------
				-- FRIEND / BEST FRIEND FOLLOW
				------------------------------------------------

				wanderTimer += deltaTime

				if wanderTimer >= nextWanderTime then
					chooseIdleAction()
				end

				local basePosition =
					playerRoot.Position
					+ playerRoot.CFrame.RightVector
						* FOLLOW_DISTANCE

				local desiredPosition =
					basePosition
					+ wanderOffset

				desiredPosition =
					Vector3.new(
						desiredPosition.X,
						currentPosition.Y,
						desiredPosition.Z
					)

				local offset =
					desiredPosition
					- currentPosition

				local distance =
					offset.Magnitude

				------------------------------------------------
				-- TELEPORT IF VERY FAR
				------------------------------------------------

				if distance >
					TELEPORT_DISTANCE then

					local teleportPosition =
						basePosition

					local direction =
						playerRoot.Position
						- teleportPosition

					if direction.Magnitude
						< 0.01 then

						direction =
							Vector3.new(
								0,
								0,
								-1
							)

					else

						direction =
							direction.Unit
					end

					companion:PivotTo(
						CFrame.lookAt(
							teleportPosition,
							teleportPosition
								+ direction
						)
					)

					wanderOffset =
						Vector3.zero

					wandering = false

					return
				end

				------------------------------------------------
				-- FOLLOW
				------------------------------------------------

				if distance >
					STOP_DISTANCE then

					moveCompanionTowards(
						currentPosition,
						desiredPosition,
						speed,
						deltaTime
					)

					if walkTrack
						and not walkTrack.IsPlaying then

						stopTrack(idleTrack)
						stopTrack(quirkTrack)

						walkTrack:Play(0.15)
					end

				else

					wandering = false

					if walkTrack
						and walkTrack.IsPlaying then

						walkTrack:Stop(0.2)
					end

					if not doingQuirk then

						if idleTrack
							and not idleTrack.IsPlaying then

							idleTrack:Play(0.2)
						end
					end
				end
			end
		)
end

------------------------------------------------------------
-- REMOVE COMPANION
------------------------------------------------------------

local function removeCompanion()

	if followConnection then

		followConnection:Disconnect()

		followConnection = nil
	end

	stopTrack(idleTrack)
	stopTrack(walkTrack)
	stopTrack(quirkTrack)

	if idleTrack then
		pcall(function()
			idleTrack:Destroy()
		end)
	end

	if walkTrack then
		pcall(function()
			walkTrack:Destroy()
		end)
	end

	if quirkTrack then
		pcall(function()
			quirkTrack:Destroy()
		end)
	end

	idleTrack = nil
	walkTrack = nil
	quirkTrack = nil

	companionHumanoid = nil
	companionRoot = nil
	currentProfile = nil

	wanderOffset =
		Vector3.zero

	wanderTimer = 0
	wandering = false
	doingQuirk = false

	friendshipBar = nil
	friendshipFill = nil
	friendshipLabel = nil
	relationshipStatusLabel = nil

	approachPhase = false
	firstMeetingPlayed = false

	strangerPhase = false
	noticeTimer = 0
	nextNoticeTime = 0
	hasNoticedPlayer = false
	strangerHomePosition = nil

	dialogueTimer = 0
	quirkTimer = 0

	crushRollTimer = 0
	nextCrushRoll = 0

	--------------------------------------------------------
	-- IMPORTANT:
	-- friendshipValue and crushActive are NOT reset here.
	-- This allows the relationship to survive player respawns.
	--------------------------------------------------------

	if companion then

		companion:Destroy()

		companion = nil
	end
end

------------------------------------------------------------
-- CREATE LOCAL COMPANION
------------------------------------------------------------

local function createLocalCompanion(
	userId,
	aiName,
	personality
)

	removeCompanion()

	local character =
		player.Character

	if not character then
		return false, "No character."
	end

	local playerRoot =
		character:
			FindFirstChild(
				"HumanoidRootPart"
			)

	if not playerRoot then
		return false,
			"Character is not ready."
	end

	currentCharacter =
		character

	local model

	if userId == player.UserId then

		model =
			character:Clone()

	else

		local descriptionSuccess,
			description =

			pcall(function()

				return Players:
					GetHumanoidDescriptionFromUserId(
						userId
					)
			end)

		if descriptionSuccess
			and description then

			local modelSuccess,
				result =

				pcall(function()

					return Players:
						CreateHumanoidModelFromDescription(
							description,
							Enum.HumanoidRigType.R15
						)
				end)

			if modelSuccess
				and result then

				model = result
			end
		end
	end

	if not model then

		return false,
			"Roblox did not allow the avatar to be created locally."
	end

	model.Name =
		aiName

	prepareCompanion(model)

	model.Parent =
		workspace

	companion =
		model

	companionHumanoid =
		model:FindFirstChildOfClass(
			"Humanoid"
		)

	companionRoot =
		model:FindFirstChild(
			"HumanoidRootPart"
		)

	if not companionHumanoid
		or not companionRoot then

		removeCompanion()

		return false,
			"Avatar is missing its R15 HumanoidRootPart."
	end

	currentProfile =
		getPersonalityProfile(
			personality
		)

	companionHumanoid.AutoJumpEnabled =
		false

	companionHumanoid.JumpPower =
		0

	companionHumanoid.DisplayDistanceType =
		Enum.HumanoidDisplayDistanceType.None

	--------------------------------------------------------
	-- SPAWN
	--------------------------------------------------------

	local spawnPosition

	if friendshipEnabled then

		----------------------------------------------------
		-- Spawn BEHIND/FAR from player.
		----------------------------------------------------

		spawnPosition =
			playerRoot.Position
			+ playerRoot.CFrame.LookVector
				* FRIENDSHIP_SPAWN_DISTANCE

	else

		spawnPosition =
			playerRoot.Position
			+ playerRoot.CFrame.RightVector
				* FOLLOW_DISTANCE
	end

	spawnPosition +=
		Vector3.new(
			0,
			0.1,
			0
		)

	local lookDirection =
		playerRoot.Position
		- spawnPosition

	if lookDirection.Magnitude < 0.01 then

		lookDirection =
			Vector3.new(
				0,
				0,
				-1
			)

	else

		lookDirection =
			lookDirection.Unit
	end

	model:PivotTo(
		CFrame.lookAt(
			spawnPosition,
			spawnPosition
				+ lookDirection
		)
	)

	createNameTag(
		model,
		aiName
	)

	--------------------------------------------------------
	-- FRIENDSHIP INITIALIZATION
	--------------------------------------------------------

	if friendshipEnabled then

		----------------------------------------------------
		-- Only start at zero for a brand new AI.
		----------------------------------------------------

		if savedAI == nil then

			friendshipValue = 0
			crushActive = false

		end

		createFriendshipMeter(
			model
		)

		updateFriendshipMeter()

		----------------------------------------------------
		-- STRANGER MODE
		----------------------------------------------------

		strangerPhase = true

		hasNoticedPlayer = false

		approachPhase = false

		firstMeetingPlayed = false

		noticeTimer = 0

		nextNoticeTime =
			random:NextNumber(
				NOTICE_MIN_TIME,
				NOTICE_MAX_TIME
			)

		strangerHomePosition =
			spawnPosition

	else

		strangerPhase = false

		hasNoticedPlayer = true

		approachPhase = false
	end

	setupAnimations(
		companionHumanoid,
		currentProfile
	)

	startFollowing()

	return true
end

------------------------------------------------------------
-- BUILD PERSONALITY
------------------------------------------------------------

local function buildPersonality()

	local personality =
		personalityBox.Text

	local selected = {}

	for trait, enabled in pairs(
		selectedTraits
	) do

		if enabled then

			table.insert(
				selected,
				trait
			)
		end
	end

	if #selected > 0 then

		if personality ~= "" then

			personality =
				personality
				.. "\n\nTraits: "
				.. table.concat(
					selected,
					", "
				)

		else

			personality =
				"Traits: "
				.. table.concat(
					selected,
					", "
				)
		end
	end

	return personality
end

------------------------------------------------------------
-- VERIFY FRIEND
------------------------------------------------------------

local function verifyFriend(userId)

	if userId ==
		player.UserId then

		return true
	end

	for _, friend in ipairs(
		friendList
	) do

		if tonumber(friend.Id)
			== tonumber(userId) then

			return true
		end
	end

	local success, result =
		pcall(function()

			return player:
				IsFriendsWith(
					userId
				)
		end)

	if success then
		return result == true
	end

	return false
end

------------------------------------------------------------
-- CREATE BUTTON
------------------------------------------------------------

createButton.Activated:Connect(
	function()

		if companionCreated then
			return
		end

		play(clickSound)

		local aiName =
			nameBox.Text:gsub(
				"%s+",
				" "
			)

		aiName =
			aiName:match(
				"^%s*(.-)%s*$"
			)

		if not aiName
			or aiName == "" then

			status.Text =
				"Give your AI a name."

			play(errorSound)

			return
		end

		local personality =
			buildPersonality()

		if personality:gsub(
			"%s+",
			""
		) == "" then

			status.Text =
				"Give your AI a personality."

			play(errorSound)

			return
		end

		local callsPlayer =
			callsBox.Text:gsub(
				"%s+",
				" "
			)

		callsPlayer =
			callsPlayer:match(
				"^%s*(.-)%s*$"
			)

		if not callsPlayer
			or callsPlayer == "" then

			status.Text =
				"Tell your AI what to call you."

			play(errorSound)

			return
		end

		local avatarUserId =
			player.UserId

		if selectedMode == "User" then

			if usernameBox.Text:gsub(
				"%s+",
				""
			) == "" then

				status.Text =
					"Enter a username."

				play(errorSound)

				return
			end

			status.Text =
				"Looking up avatar..."

			local userId =
				getUserId(
					usernameBox.Text
				)

			if not userId then

				status.Text =
					"Username not found."

				play(errorSound)

				return
			end

			avatarUserId =
				userId

		elseif selectedMode == "Friend" then

			if not selectedFriend then

				status.Text =
					"Choose a friend first."

				play(errorSound)

				return
			end

			avatarUserId =
				tonumber(
					selectedFriend.Id
				)

			if not avatarUserId then

				status.Text =
					"Invalid friend selection."

				play(errorSound)

				return
			end

			status.Text =
				"Checking friendship..."

			if not verifyFriend(
				avatarUserId
			) then

				status.Text =
					"That user isn't your friend."

				play(errorSound)

				return
			end
		end

		----------------------------------------------------
		-- SAVE AI
		----------------------------------------------------

		savedAI = {
			Name = aiName,

			Personality =
				personality,

			CallsPlayer =
				callsPlayer,

			AvatarUserId =
				avatarUserId,

			AvatarMode =
				selectedMode,

			FriendshipEnabled =
				friendshipEnabled
		}

		----------------------------------------------------
		-- New AI starts relationship at zero.
		----------------------------------------------------

		friendshipValue = 0
		crushActive = false
		lastRelationshipStage =
			"Stranger"

		status.Text =
			"Creating your AI..."

		createButton.Visible =
			false

		local success,
			errorMessage =

			createLocalCompanion(
				avatarUserId,
				aiName,
				personality
			)

		if not success then

			createButton.Visible =
				true

			status.Text =
				tostring(
					errorMessage
					or "Could not create AI."
				)

			savedAI = nil

			play(errorSound)

			return
		end

		companionCreated =
			true

		startOverButton.Visible =
			true

		status.Text =
			aiName
			.. " is alive!"

		play(successSound)
	end
)

------------------------------------------------------------
-- START OVER
------------------------------------------------------------

startOverButton.Activated:Connect(
	function()

		if not companionCreated then
			return
		end

		play(deleteSound)

		removeCompanion()

		companionCreated =
			false

		savedAI = nil

		----------------------------------------------------
		-- Starting over is a NEW relationship.
		----------------------------------------------------

		friendshipValue = 0
		crushActive = false

		lastRelationshipStage =
			"Stranger"

		createButton.Visible =
			true

		startOverButton.Visible =
			false

		status.Text =
			"AI deleted. Ready to create another."
	end
)

------------------------------------------------------------
-- OPEN / CLOSE
------------------------------------------------------------

local function openPanel()

	play(openSound)

	panel.Visible =
		true

	panelScale.Scale =
		0.9

	tween(
		panelScale,
		0.3,
		{
			Scale = 1
		}
	)

	openButton.Visible =
		false
end

local function closePanel()

	play(clickSound)

	tween(
		panelScale,
		0.18,
		{
			Scale = 0.9
		}
	)

	task.delay(
		0.18,
		function()

			panel.Visible =
				false
		end
	)

	openButton.Visible =
		true
end

openButton.Activated:Connect(
	openPanel
)

closeButton.Activated:Connect(
	closePanel
)

------------------------------------------------------------
-- BUTTON PRESS ANIMATION
------------------------------------------------------------

local function buttonPress(button)

	local original =
		button.Size

	button.InputBegan:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.Touch

				or input.UserInputType ==
				Enum.UserInputType.MouseButton1 then

				tween(
					button,
					0.08,
					{
						Size =
							UDim2.new(
								original.X.Scale,
								original.X.Offset - 3,
								original.Y.Scale,
								original.Y.Offset - 3
							)
					}
				)
			end
		end
	)

	button.InputEnded:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.Touch

				or input.UserInputType ==
				Enum.UserInputType.MouseButton1 then

				tween(
					button,
					0.1,
					{
						Size =
							original
					}
				)
			end
		end
	)
end

buttonPress(openButton)
buttonPress(closeButton)
buttonPress(createButton)
buttonPress(startOverButton)

------------------------------------------------------------
-- CHARACTER RESPAWN
------------------------------------------------------------

player.CharacterAdded:Connect(
	function(character)

		currentCharacter =
			character

		if not savedAI then

			removeCompanion()

			return
		end

		----------------------------------------------------
		-- Do NOT destroy the relationship progress.
		----------------------------------------------------

		removeCompanion()

		character:
			WaitForChild(
				"HumanoidRootPart"
			)

		character:
			WaitForChild(
				"Humanoid"
			)

		task.wait(0.75)

		if savedAI then

			friendshipEnabled =
				savedAI.FriendshipEnabled
				== true

			local success,
				errorMessage =

				createLocalCompanion(
					savedAI.AvatarUserId,
					savedAI.Name,
					savedAI.Personality
				)

			if success then

				companionCreated =
					true

				status.Text =
					savedAI.Name
					.. " is back!"

			else

				status.Text =
					"AI could not respawn: "
					.. tostring(
						errorMessage
						or "Unknown error."
					)
			end
		end
	end
)

------------------------------------------------------------
-- CAMERA / RESPONSIVE UI
------------------------------------------------------------

currentCharacter =
	player.Character

local camera =
	workspace.CurrentCamera

local function updateScale()

	camera =
		workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport =
		camera.ViewportSize

	if viewport.X <= 500 then

		panel.Size =
			UDim2.new(
				0.94,
				0,
				0.88,
				0
			)

	else

		panel.Size =
			UDim2.fromOffset(
				PANEL_WIDTH,
				PANEL_HEIGHT
			)
	end

	if viewport.Y <= 650 then

		panel.Size =
			UDim2.new(
				panel.Size.X.Scale,
				panel.Size.X.Offset,
				0.92,
				0
			)
	end

	if viewport.X <= 360 then

		panelScale.Scale =
			0.88

	else

		panelScale.Scale =
			1
	end
end

if camera then

	camera:
		GetPropertyChangedSignal(
			"ViewportSize"
		):Connect(
			updateScale
		)
end

updateScale()

------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------

script.Destroying:Connect(
	function()

		removeCompanion()

		for _, sound in ipairs(
			SoundService:GetChildren()
		) do

			if sound.Name == "AI_Click"
				or sound.Name == "AI_Open"
				or sound.Name == "AI_Success"
				or sound.Name == "AI_Delete"
				or sound.Name == "AI_Error" then

				sound:Destroy()
			end
		end
	end
)
