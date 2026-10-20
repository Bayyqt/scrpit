--[[
    ===================================================================
    MOTION CORE VIP LOADER - OPEN SOURCE REWRITE
    ===================================================================
    - UI Library : Motion Core Forest Market UI (Official Repository)
    - Status     : Clean, Un-obfuscated, Full Custom Control
    - Executor   : Solara, Delta, Wave, Codex, Fluxus, Hydrogen, dll.
    ===================================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 1. Load Official Motion Core UI Library
local LibraryUrl = "https://raw.githubusercontent.com/MotionCoreOfficial/MotionCore-Loader/refs/heads/main/libraries/forest_market_ui.lua"
local success, Library = pcall(function()
    return loadstring(game:HttpGet(LibraryUrl))()
end)

if not success or not Library then
    warn("[MotionCore] Gagal memuat UI Library dari GitHub!")
    return
end

-- 2. Buat Jendela Utama Motion Core
local Window = Library:CreateWindow({
    Title = "Motion Core VIP",
    SubTitle = "Open-Source Edition",
    ConfigFolder = "MotionCore/VIP",
    Config = {
        AutoLoad = false,
        AutoSave = false,
        AutoSaveFile = "VIP_Settings"
    }
})

-- 3. Variabel Konfigurasi & State
local State = {
    Speed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    AvatarShake = false,
    ShakeIntensity = 1.5,
    Fullbright = false
}

-- ===================================================================
-- TAB 1: PLAYER (Karakter & Movement)
-- ===================================================================
local TabPlayer = Window:AddTab({ Name = "Player" })
local BoxPlayer = TabPlayer:AddLeftTabbox("Movement & Physic")
local PagePlayer = BoxPlayer:AddTab("Main")

-- WalkSpeed Slider
PagePlayer:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Decimals = 0,
    Callback = function(val)
        State.Speed = val
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
        end
    end
})

-- JumpPower Slider
PagePlayer:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 400,
    Default = 50,
    Decimals = 0,
    Callback = function(val)
        State.JumpPower = val
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            hum.UseJumpPower = true
            hum.JumpPower = val
        end
    end
})

-- Infinite Jump Toggle
PagePlayer:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(enabled)
        State.InfiniteJump = enabled
    end
})

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip Toggle
PagePlayer:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(enabled)
        State.Noclip = enabled
    end
})

RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Fly Toggle
local flyBodyGyro, flyBodyVelocity
PagePlayer:AddToggle({
    Name = "Fly Mode",
    Default = false,
    Callback = function(enabled)
        State.Fly = enabled
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        if enabled then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.P = 9e4
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.CFrame = root.CFrame
            flyBodyGyro.Parent = root

            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.Velocity = Vector3.zero
            flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVelocity.Parent = root
        else
            if flyBodyGyro then flyBodyGyro:Destroy() end
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
        end
    end
})

PagePlayer:AddSlider({
    Name = "Fly Speed",
    Min = 20,
    Max = 250,
    Default = 50,
    Decimals = 0,
    Callback = function(val)
        State.FlySpeed = val
    end
})

RunService.RenderStepped:Connect(function()
    if State.Fly and flyBodyVelocity and flyBodyGyro and LocalPlayer.Character then
        local cam = workspace.CurrentCamera
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        flyBodyGyro.CFrame = cam.CFrame
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        flyBodyVelocity.Velocity = moveDir * State.FlySpeed
    end
end)

-- Reset Character Button
PagePlayer:AddButton({
    Name = "Respawn / Reset Character",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
        end
    end
})

-- ===================================================================
-- TAB 2: MOTION CORE EXCLUSIVE (Avatar Shake)
-- ===================================================================
local TabMotion = Window:AddTab({ Name = "MotionCore" })
local BoxMotion = TabMotion:AddLeftTabbox("Motion Core FX")
local PageMotion = BoxMotion:AddTab("Avatar FX")

PageMotion:AddToggle({
    Name = "Avatar Shake Effect",
    Default = false,
    Callback = function(enabled)
        State.AvatarShake = enabled
    end
})

PageMotion:AddSlider({
    Name = "Shake Intensity",
    Min = 1,
    Max = 10,
    Default = 2,
    Decimals = 1,
    Callback = function(val)
        State.ShakeIntensity = val
    end
})

-- Avatar Shake Loop
task.spawn(function()
    while true do
        task.wait(0.04)
        if State.AvatarShake and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local offsetX = (math.random() - 0.5) * (State.ShakeIntensity * 0.15)
                local offsetZ = (math.random() - 0.5) * (State.ShakeIntensity * 0.15)
                root.CFrame = root.CFrame * CFrame.new(offsetX, 0, offsetZ)
            end
        end
    end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
PageMotion:AddToggle({
    Name = "Anti-AFK Protection",
    Default = true,
    Callback = function(enabled)
        State.AntiAFK = enabled
    end
})

LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end
end)

-- ===================================================================
-- TAB 3: SCRIPT LOADER & UTILITIES
-- ===================================================================
local TabLoader = Window:AddTab({ Name = "Custom Loader" })
local BoxLoader = TabLoader:AddLeftTabbox("Run Custom Script")
local PageLoader = BoxLoader:AddTab("Loader")

local targetScriptUrl = ""
PageLoader:AddTextInput({
    Name = "Script Raw URL",
    Placeholder = "https://raw.githubusercontent.com/...",
    Callback = function(text)
        targetScriptUrl = text
    end
})

PageLoader:AddButton({
    Name = "Execute Script URL",
    Callback = function()
        if targetScriptUrl and #targetScriptUrl > 5 then
            local runSuccess, err = pcall(function()
                loadstring(game:HttpGet(targetScriptUrl))()
            end)
            if not runSuccess then
                warn("[MotionCore] Gagal eksekusi: " .. tostring(err))
            end
        end
    end
})

PageLoader:AddButton({
    Name = "Close / Unload UI",
    Callback = function()
        Window:Destroy()
    end
})

-- Notifikasi Berhasil Dimuat
Window:Notify({
    Title = "Motion Core VIP",
    Content = "Loader berhasil dimuat (Open-Source Edition)",
    Duration = 4
})
