local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ParseInt = ____lualib.__TS__ParseInt
local ____exports = {}
local ____tools = require("Plugins.LuaPanda.src.common.tools")
local Tools = ____tools.Tools
local ____logManager = require("Plugins.LuaPanda.src.common.logManager")
local DebugLogger = ____logManager.DebugLogger
local ____visualSetting = require("Plugins.LuaPanda.src.debug.visualSetting")
local VisualSetting = ____visualSetting.VisualSetting
local vscode = require("Plugins.LuaPanda.src.debug.vscode")
local fs = require("Plugins.LuaPanda.src.debug.fs")
____exports.UpdateManager = __TS__Class()
local UpdateManager = ____exports.UpdateManager
UpdateManager.name = "UpdateManager"
function UpdateManager.prototype.____constructor(self)
end
function UpdateManager.prototype.setCheckUpdate(self, state)
    ____exports.UpdateManager.checkUpdate = state
end
function UpdateManager.prototype.checkIfLuaPandaNeedUpdate(self, LuaPandaPath, rootFolder)
    if not ____exports.UpdateManager.checkUpdate or not LuaPandaPath then
        return
    end
    local luapandaTxt = Tools:readFileContent(LuaPandaPath)
    local dver = luapandaTxt:match(nil)
    if dver and #dver == 3 then
        local DVerArr = __TS__StringSplit(dver[3], ".")
        local AVerArr = __TS__StringSplit(
            String(nil, Tools.adapterVersion),
            "."
        )
        if #DVerArr == #AVerArr and #DVerArr == 3 then
            local intDVer = __TS__ParseInt(DVerArr[1]) * 10000 + __TS__ParseInt(DVerArr[2]) * 100 + __TS__ParseInt(DVerArr[3])
            local intAVer = __TS__ParseInt(AVerArr[1]) * 10000 + __TS__ParseInt(AVerArr[2]) * 100 + __TS__ParseInt(AVerArr[3])
            local updateTipSetting = VisualSetting:getLaunchjson(rootFolder, "updateTips")
            if intDVer < intAVer and updateTipSetting ~= false then
                vscode.window:showInformationMessage(
                    ("LuaPanda VSCode 插件已升级 " .. tostring(Tools.adapterVersion)) .. " 版本, 建议同时升级 LuaPanda.lua 文件。首次开始调试前请重建一下 launch.json 文件, 避免产生兼容问题。launch.json 配置项目参考 https://github.com/Tencent/LuaPanda/blob/master/Docs/Manual/launch-json-introduction.md",
                    "好的"
                )
                local ____self_1 = vscode.window:showInformationMessage("当前工程中的 LuaPanda.lua 文件版本较低，是否自动替换为最新版本?", "Yes", "No", "Never")
                ____self_1["then"](
                    ____self_1,
                    function(____, value)
                        if value == "Yes" then
                            local confirmButton = "立刻升级"
                            local ____self_0 = vscode.window:showInformationMessage(
                                ("已准备好更新 " .. tostring(LuaPandaPath)) .. "。如用户对此文件有修改, 建议备份后再升级, 避免修改内容被覆盖",
                                confirmButton,
                                "稍后再试"
                            )
                            ____self_0["then"](
                                ____self_0,
                                function(____, value)
                                    if value == confirmButton then
                                        self:updateLuaPandaFile(LuaPandaPath)
                                    end
                                end
                            )
                        elseif value == "No" then
                            vscode.window:showInformationMessage("本次运行期间 LuaPanda 将不再弹出升级提示", "好的")
                            self:setCheckUpdate(false)
                        elseif value == "Never" then
                            vscode.window:showInformationMessage("本项目调试时将不会再弹出调试器升级提示，需要升级请参考 https://github.com/Tencent/LuaPanda/blob/master/Docs/Manual/update.md", "好的")
                            self:setCheckUpdate(false)
                            VisualSetting:setLaunchjson(rootFolder, "updateTips", false)
                        end
                    end
                )
            end
        else
        end
    end
end
function UpdateManager.prototype.updateLuaPandaFile(self, LuaPandaPath)
    local luapandaContent = fs:readFileSync(Tools:getLuaPathInExtension())
    do
        local function ____catch(____error)
            DebugLogger:showTips(
                ("升级失败, " .. tostring(LuaPandaPath)) .. "写入失败! 可以手动替换此文件到github最新版",
                1
            )
        end
        local ____try, ____hasReturned = pcall(function()
            fs:writeFileSync(LuaPandaPath, luapandaContent)
            DebugLogger:showTips(
                (("升级成功, " .. tostring(LuaPandaPath)) .. " 已升级到 ") .. tostring(Tools.adapterVersion),
                0
            )
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
        do
            self:setCheckUpdate(false)
        end
    end
end
UpdateManager.checkUpdate = true
return ____exports
