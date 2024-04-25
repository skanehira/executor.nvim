local M = {};

function M.setup()
  vim.api.nvim_create_user_command('ExecutorRun', function()
    M.run();
  end, {})
end

function M.run()
  local bufnum = vim.fn.bufnr('%')
  local range = M.get_code_block(bufnum)
  local content = M.get_code_from_range(bufnum, range[1])
  local result = M.execute(content)
  vim.print(result)
end

--- get code block using treesitter
--- @param bufnum integer
--- @return integer[][]
function M.get_code_block(bufnum)
  local parser = vim.treesitter.get_parser(bufnum)
  local lang = parser:lang()
  local query = vim.treesitter.query.get(lang, 'quickrun')

  local tree = parser:parse()[1]
  local root_node = tree:root()
  local iterator = query:iter_matches(root_node, bufnum)
  local range = vim.iter(iterator):map(function(...)
    local _, captured = ...
    local range = { captured[1]:range() }
    return range
  end):totable()

  return range
end

function M.get_code_from_range(bufnum, range)
  local lines = vim.api.nvim_buf_get_lines(bufnum, range[1], range[3], false)
  return table.concat(lines, '\n')
end

function M.execute(content)
  local result = vim.system({'bash', '-c', content}):wait()
  return result.stdout
end

return M
