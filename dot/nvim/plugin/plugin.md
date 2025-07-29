# nvim/plugin/

`*.lua` files within this directory are run on startup.

> [!NOTE]
> LazyVim uses `nvim/lua/{plugins,config}/`.

## Commands

1. Implement as Lua function in `nvim/lua/`. For example:
   `nvim/lua/functions/digraph.lua`
1. Add a delegating user-command in `plugin/commands.lua` via the
   `nvim_create_user_command` API.
1. Can call as `:Command<cr>`

- Avoid `nvim/lua/plugins/`
  - unless related to a plugin, then use `nvim/lua/plugins/*/*.lua`
