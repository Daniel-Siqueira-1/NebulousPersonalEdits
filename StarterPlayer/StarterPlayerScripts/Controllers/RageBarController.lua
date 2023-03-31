local RageBarController = {}

local TweenService = game:GetService("TweenService")
local BarTweenInfo = TweenInfo.new(.15)

local AnimationValue = Instance.new('NumberValue')

function RageBarController:Start()
    self.RageBar = self.PlayerGui:WaitForChild("Main"):WaitForChild("Self"):WaitForChild("Rage")

    local function UpdateBar(NewAmount)
        local TweenEffect = TweenService:Create(self.RageBar) -- will continue this later since it's just an UI animation
    end 

    UpdateBar(100)
    self.Bridges.Combat.RageUpdated:Connect(UpdateBar)
end

return RageBarController
