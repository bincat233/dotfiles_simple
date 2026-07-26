-- Plugin version overrides for the last releases compatible with Neovim 0.9.
-- Add entries here when a plugin's current release raises its minimum version.
return {
  ["mini.nvim"] = {
    checkout = "v0.17.0",
    monitor = "stable",
  },
  catppuccin = {
    checkout = "v1.11.0",
    monitor = "main",
  },
}
