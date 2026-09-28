--- @type Gears_Namespace
local ns = select(2, ...)
local L = ns:GetLocale()

--[[-----------------------------------------------------------------------------
Gears_HelpTipMixin
@see Help.xml
-------------------------------------------------------------------------------]]
--- @class Gears_HelpTipMixin : Frame
--- @field Text FontString
--- @field CloseButton Button
--- @field Arrow Frame
--- @field tipKey string  @Key in global.helpTipsDismissed; set per instance in XML
--- @field textKey string @Locale key of the tip text; set per instance in XML
Gears_HelpTipMixin = {}; local o = Gears_HelpTipMixin

--
--- @class Gears_HelpTip : Gears_HelpTipMixin
--

function o:OnLoad()
  self.Text:SetText(L[self.textKey])
  self.CloseButton:SetScript("OnClick", function() self:Dismiss() end)
end

--- Points the arrow at the top center of anchorTo
--- @param anchorTo Region? @nil hides the tip
function o:ShowOnce(anchorTo)
  if not anchorTo or ns:g().helpTipsDismissed[self.tipKey] then self:Hide(); return end

  -- Set here: the parent raises its level after our OnLoad
  self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10)
  self:ClearAllPoints()
  -- Centers the arrow over anchorTo
  self:SetPoint("BOTTOMLEFT", anchorTo, "TOP", -34, 19)
  self:SetHeight(self.Text:GetHeight() + 32)
  self:Show()
end

function o:Dismiss()
  self:Hide()
  ns:g().helpTipsDismissed[self.tipKey] = true
end
