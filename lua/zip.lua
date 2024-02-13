local M = {}

function M.zipper(is_branch, children, make_node, tree)
    return {
        -- The current node we're looking at.
        focus = tree,
        -- Nodes higher up in the tree.
        -- A path entry looks like this:
        -- {
        --     -- The node at this path entry. Includes any (potentially old) children.
        --     node = <>,
        --     -- A list of nodes to the left of  the current focus.
        --     left = { <> },
        --     -- A list of nodes to the right of the current focus.
        --     right = { <> },
        -- }
        -- To construct the children for `node` we concatenate `left`, `zipper.focus`, and `right`.
        path = {},

        is_branch = is_branch,
        children = children,
        make_node = make_node,
    }
end

function M.node(zipper)
    return utils.clone(zipper.focus)
end

function M.is_branch(zipper)
    return zipper.is_branch(M.node(zipper))
end

function M.children(zipper)
    return zipper.children(M.node(zipper))
end

function M.make_node(zipper, node, children)
    return zipper.make_node(node, children)
end

function M.path(zipper)
    return utils.clone(zipper.path)
end

function M.lefts(zipper)
    -- TODO: Test
    return utils.clone(zipper.path[#zipper.path].left)
end

function M.rights(zipper)
    -- TODO: Test
    return utils.clone(zipper.path[#zipper.path].right)
end

function M.down(zipper)
end

function M.up(zipper)
end

function M.left(zipper)
end

function M.right(zipper)
end

function M.leftmost(zipper)
end

function M.rightmost(zipper)
end

function M.append_child(zipper, child)
end

return M
