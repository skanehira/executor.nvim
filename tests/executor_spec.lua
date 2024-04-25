describe('get_code_block', function()
  it('should get code block', function()
    local bufnum = vim.api.nvim_create_buf(false, true)
    vim.bo[bufnum].filetype = 'markdown'
    vim.api.nvim_buf_set_lines(bufnum, 0, -1, false, {
      '```sh',
      'echo "hello, world"',
      '```',
    })

    local quickrun = require('quickrun')
    quickrun.setup()
    local range = quickrun.get_code_block(bufnum)
    assert.are.same(range, { { 1, 0, 2, 0 } })

    local got = quickrun.get_code_from_range(bufnum, range[1])
    assert.are.same(got, 'echo "hello, world"')
  end)
end)
