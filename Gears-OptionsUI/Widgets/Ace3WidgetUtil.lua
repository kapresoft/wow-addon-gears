--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Gears_OptionsUI_Namespace
local ns = select(2, ...)
local cns = ns:cns()
local CONFIG = ns.Ace3WidgetConfig
local ACD = cns:AceConfigDialog()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- Tooltip helpers for our AceGUI widgets
--- @class Gears_Ace3WidgetUtil
local o = {}; ns.Ace3WidgetUtil = o

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param widget AceGUIWidget
--- @param tooltip GameTooltip
--- @param context ScriptRegion
function o:AnchorTooltip(widget, tooltip, context)
  local offset = CONFIG:Layout(widget).tooltip
  tooltip:SetAnchorType('ANCHOR_NONE')
  tooltip:ClearAllPoints()
  tooltip:SetPoint('BOTTOMLEFT', context, 'TOPRIGHT', offset.x, offset.y)
end

--- Also moves AceConfigDialog's tooltip beside the context
--- @param widget AceGUIWidget
--- @param context ScriptRegion
function o:FireEnter(widget, context)
  widget:Fire('OnEnter')
  local tooltip = ACD and ACD.tooltip
  if not (tooltip and tooltip:IsShown() and tooltip:GetOwner() == widget.frame) then return end
  self:AnchorTooltip(widget, tooltip, context)
end
