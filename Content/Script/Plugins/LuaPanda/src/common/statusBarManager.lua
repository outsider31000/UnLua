local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local vscode = require("Plugins.LuaPanda.src.common.vscode")
____exports.StatusBarManager = __TS__Class()
local StatusBarManager = ____exports.StatusBarManager
StatusBarManager.name = "StatusBarManager"
function StatusBarManager.prototype.____constructor(self)
end
function StatusBarManager.init(self)
    self.MemStateBar = vscode.window:createStatusBarItem(vscode.StatusBarAlignment.Left, 5)
    self.MemStateBar.tooltip = "Click to collect garbage"
    self.MemStateBar.command = "luapanda.LuaGarbageCollect"
    self.Setting = vscode.window:createStatusBarItem(vscode.StatusBarAlignment.Left, 6)
    self.Setting.tooltip = "Click open setting page"
    self.Setting.command = "luapanda.openSettingsPage"
    self.Setting:hide()
end
function StatusBarManager.refreshLuaMemNum(self, num)
    self.MemStateBar.text = String(nil, num) .. "KB"
    self.MemStateBar:show()
end
function StatusBarManager.showSetting(self, message)
    self.Setting.text = message
    self.Setting:show()
end
function StatusBarManager.reset(self)
end
return ____exports
