-- TODO: Name
--       - SelectedTree?
--       - PavedTree?
--
-- Each node of the tree looks like this:
-- {
--     data = <some data>,
--     selected_child = <index of the selected child> | nil,
--     children = {
--         <child 1>,
--         <child 2>,
--         ...
--     },
-- }
-- Each child is also a node.

local utils = require("neoai2.utils")

local M = {}

function M.node(data, selected_child, children)
    if selected_child == nil then
        if children ~= nil then
            error("selected_child must be specified if children are specified")
        end

        return {
            data = data,
            selected_child = nil,
            children = {},
        }
    end

    if selected_child < 1 or selected_child > #children then
        error("selected_child must be a valid index")
    end

    return {
        data = data,
        selected_child = selected_child,
        children = children,
    }
end

function M.append_child(tree, child)
    table.insert(tree.children, child)
    tree.selected_child = #tree.children
end

function M.selected_leaf(tree)
    local selected_leaf = tree

    while selected_leaf.selected_child ~= nil do
        selected_leaf = selected_leaf.children[selected_leaf.selected_child]
    end

    return selected_leaf
end

function M.append_leaf(tree, child)
    local selected_leaf = M.selected_leaf(tree)

    M.append_child(selected_leaf, child)
end

function M.at(tree, idx)
    local selected_node = tree
    while idx > 1 do
        if selected_node.selected_child == nil then
            error("index out of bounds")
        end

        idx = idx - 1
        selected_node = selected_node.children[selected_node.selected_child]
    end
    return selected_node
end

function M.append_at(tree, idx, child)
    local selected_node = M.at(tree, idx)

    M.append_child(selected_node, child)
end

return M

-- Pros:
-- - Fairly simple implementation
-- - Get's the job done quickly
-- - Can store the tree as-is and open with the most recent selection
-- Cons:
-- - Mutates the tree
-- - Must know the index you wish to append at
local tree = M.node("system")

M.append_leaf(tree, M.node("user"))
M.append_leaf(tree, M.node("assistant"))
M.append_leaf(tree, M.node("user"))
M.append_leaf(tree, M.node("assistant"))

M.append_at(tree, 3, M.node("user 2"))
M.append_leaf(tree, M.node("assistant 2"))
