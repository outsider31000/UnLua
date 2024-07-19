local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local ____exports = {}
local treeNode = __TS__Class()
treeNode.name = "treeNode"
function treeNode.prototype.____constructor(self)
    self.childrenNode = __TS__New(Object)
    self.symbols = __TS__New(Array)
end
____exports.trieTree = __TS__Class()
local trieTree = ____exports.trieTree
trieTree.name = "trieTree"
function trieTree.prototype.____constructor(self)
end
function trieTree.createSymbolTree(self, symbolArray)
    if not __TS__ArrayIsArray(symbolArray) or #symbolArray == 0 then
        return
    end
    local root = __TS__New(treeNode)
    root.thisChr = "TREE_ROOT"
    for ____, symbol in ipairs(symbolArray) do
        self:addNodeOnTrieTree(root, symbol)
    end
    return root
end
function trieTree.searchOnTrieTree(self, root, searchKey, searchChildren)
    if searchChildren == nil then
        searchChildren = true
    end
    if not root or not searchKey or searchKey == "" then
        return
    end
    local currentPtr = root
    searchKey = searchKey:toLowerCase()
    local searchArray = searchKey:split("")
    do
        local index = 0
        while index < searchArray.length do
            local it = searchArray[index]
            if not currentPtr.childrenNode[it] then
                return
            end
            currentPtr = currentPtr.childrenNode[it]
            if index == searchArray.length - 1 then
                local searchResult = self:travelAllNode(currentPtr, searchChildren)
                return searchResult
            end
            index = index + 1
        end
    end
end
function trieTree.searchOnTrieTreeWithoutTableChildren(self, root, searchKey)
    return self:searchOnTrieTree(root, searchKey, false)
end
function trieTree.addNodeOnTrieTree(self, root, symbol)
    local currentPtr = root
    local searchName = symbol.searchName:toLowerCase()
    local searchArray = searchName:split("")
    do
        local index = 0
        while index < searchArray.length do
            local it = searchArray[index]
            if not currentPtr.childrenNode[it] then
                local newNode = __TS__New(treeNode)
                newNode.thisChr = it
                currentPtr.childrenNode[it] = newNode
            end
            currentPtr = currentPtr.childrenNode[it]
            if index == searchArray.length - 1 then
                currentPtr.symbols:push(symbol)
            end
            index = index + 1
        end
    end
end
function trieTree.travelAllNode(self, node, searchChildren)
    local retArray
    if node.symbols and node.symbols.length > 0 then
        retArray = node.symbols
    end
    for key in pairs(node.childrenNode) do
        local element = node.childrenNode[key]
        local childArray = {}
        if searchChildren == false and (element.thisChr == "." or element.thisChr == ":") then
        else
            childArray = self:travelAllNode(element, searchChildren)
        end
        if retArray == nil then
            retArray = childArray
        else
            retArray = retArray:concat(childArray)
        end
    end
    return retArray
end
return ____exports
