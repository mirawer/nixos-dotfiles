return {
  {
    "neovim/nvim-lspconfig",

    config = function()
      -- ZLS — Zig Language Server (nowe API Neovim 0.11+)
      vim.lsp.config('zls', {})
      vim.lsp.enable('zls')

      -- Skroty klawiszowe LSP (aktywne w buforach .zig)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          map("gd", vim.lsp.buf.definition, "Skok do definicji")
          map("gr", vim.lsp.buf.references, "Referencje")
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
        end,
      })
    end,
  },
}
