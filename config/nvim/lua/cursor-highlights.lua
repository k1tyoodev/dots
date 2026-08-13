local M = {}

-- Canvas matches Grok Build bg_base (groknight / grokday) and Ghostty.
local canvas = {
  dark = "#141414",
  light = "#eeeeee",
}

-- Syntax defaults match Cursor 3.11.19. At runtime token colors are read from
-- Cursor.app, which remains the source of truth after future Cursor updates.
local defaults = {
  dark = {
    background = canvas.dark,
    cursor = "#F0F0F0",
    syntax = "#D6D6DD",
    keyword = "#82D2CE",
    language_variable = "#CC7C8A",
    constant = "#D6D6DD",
    builtin_constant = "#82D2CE",
    number = "#EBC88D",
    func = "#EFB080",
    type = "#EFB080",
    class = "#87C3FF",
    property = "#AAA0FA",
    string = "#E394DC",
    regexp = "#D6D6DD",
    directive = "#A8CC7C",
    tag = "#87C3FF",
  },
  light = {
    background = canvas.light,
    cursor = "#141414",
    syntax = "#141414",
    keyword = "#A30034",
    language_variable = "#BE1744",
    constant = "#005293",
    builtin_constant = "#005293",
    number = "#92156A",
    func = "#CD4500",
    type = "#005293",
    class = "#005293",
    property = "#654DC0",
    string = "#7565CC",
    regexp = "#0064B0",
    directive = "#007041",
    tag = "#007041",
  },
}

local theme_paths = {
  dark = "/Applications/Cursor.app/Contents/Resources/app/extensions/theme-cursor/themes/cursor-dark-color-theme.json",
  light = "/Applications/Cursor.app/Contents/Resources/app/extensions/theme-cursor/themes/cursor-light-color-theme.json",
}

local cache = {}

local function contains_scope(scope, wanted)
  if type(scope) == "table" then
    for _, item in ipairs(scope) do
      if contains_scope(item, wanted) then
        return true
      end
    end
    return false
  end

  if type(scope) ~= "string" then
    return false
  end

  for item in scope:gmatch("[^,]+") do
    if vim.trim(item) == wanted then
      return true
    end
  end
  return false
end

local function token_color(theme, scope, fallback)
  -- Later TextMate rules take precedence when a scope appears more than once.
  for index = #theme.tokenColors, 1, -1 do
    local token = theme.tokenColors[index]
    if token.settings and token.settings.foreground and contains_scope(token.scope, scope) then
      return token.settings.foreground
    end
  end
  return fallback
end

local function load_theme(background)
  if cache[background] then
    return cache[background]
  end

  local colors = vim.deepcopy(assert(defaults[background], "unsupported Cursor theme: " .. tostring(background)))
  local file = io.open(theme_paths[background], "r")
  if not file then
    colors.background = assert(canvas[background])
    cache[background] = colors
    return colors
  end

  local ok, theme = pcall(vim.json.decode, file:read("*a"))
  file:close()
  if not ok or type(theme) ~= "table" or type(theme.tokenColors) ~= "table" then
    colors.background = assert(canvas[background])
    cache[background] = colors
    return colors
  end

  colors.background = assert(canvas[background])
  colors.cursor = theme.colors["editorCursor.foreground"] or colors.cursor
  colors.syntax = token_color(theme, "variable", colors.syntax)
  colors.keyword = token_color(theme, "keyword", colors.keyword)
  colors.language_variable = token_color(theme, "variable.language", colors.language_variable)
  colors.constant = token_color(theme, "constant", colors.constant)
  colors.builtin_constant = token_color(theme, "support.constant", colors.builtin_constant)
  colors.number = token_color(theme, "constant.numeric", colors.number)
  colors.func = token_color(theme, "entity.name.function", colors.func)
  colors.type = token_color(theme, "entity.name.type", colors.type)
  colors.class = token_color(theme, "entity.name.type.class", colors.class)
  colors.property = token_color(theme, "support.variable.property", colors.property)
  colors.string = token_color(theme, "string", colors.string)
  colors.regexp = token_color(theme, "string.regexp", colors.regexp)
  colors.directive = token_color(theme, "keyword.control.directive", colors.directive)
  colors.tag = token_color(theme, "entity.name.tag.html", colors.tag)
  cache[background] = colors
  return colors
end

local function set(group, foreground, attributes)
  vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", { fg = foreground }, attributes or {}))
end

function M.apply(background)
  local c = load_theme(background)

  -- Align editor canvas with Grok Build / Ghostty.
  vim.cmd.highlight(("Normal guibg=%s"):format(c.background))
  vim.cmd.highlight(("NormalNC guibg=%s"):format(c.background))
  vim.cmd.highlight(("SignColumn guibg=%s"):format(c.background))
  vim.cmd.highlight(("EndOfBuffer guibg=%s"):format(c.background))

  -- Editor chrome missed by cursor.nvim's generic accent mapping.
  vim.api.nvim_set_hl(0, "Cursor", { fg = c.background, bg = c.cursor })

  -- Legacy Vim syntax groups, still used when a parser is unavailable.
  set("Identifier", c.syntax)
  set("Function", c.func)
  set("Constant", c.constant)
  set("Number", c.number)
  set("Float", c.number)
  set("Boolean", c.builtin_constant)
  set("Statement", c.keyword)
  set("Conditional", c.keyword)
  set("Repeat", c.keyword)
  set("Operator", c.syntax)
  set("Keyword", c.keyword)
  set("Exception", c.keyword)
  set("PreProc", c.directive)
  set("Include", c.directive)
  set("Define", c.directive)
  set("Macro", c.directive)
  set("PreCondit", c.directive)
  set("Type", c.type)
  set("StorageClass", c.keyword)
  set("Structure", c.type)
  set("Typedef", c.type)
  set("Delimiter", c.syntax)
  set("Tag", c.tag)

  -- Tree-sitter captures corresponding to Cursor's generic TextMate scopes.
  set("@variable", c.syntax)
  set("@variable.builtin", c.language_variable)
  set("@variable.parameter", c.syntax)
  set("@variable.member", c.property)
  set("@constant", c.constant)
  set("@constant.builtin", c.builtin_constant)
  set("@constant.macro", c.directive)
  set("@module", c.type)
  set("@module.builtin", c.keyword)
  set("@string", c.string)
  set("@string.regexp", c.regexp)
  set("@number", c.number)
  set("@number.float", c.number)
  set("@type", c.type)
  set("@type.builtin", c.keyword)
  set("@type.definition", c.type)
  set("@constructor", c.type)
  set("@attribute", c.property)
  set("@property", c.property)
  set("@function", c.func)
  set("@function.builtin", c.func)
  set("@function.call", c.func)
  set("@function.method", c.func)
  set("@function.method.call", c.func)
  set("@function.macro", c.directive)
  set("@operator", c.syntax)
  set("@keyword", c.keyword)
  set("@keyword.coroutine", c.keyword)
  set("@keyword.function", c.keyword)
  set("@keyword.operator", c.syntax)
  set("@keyword.import", c.keyword)
  set("@keyword.type", c.keyword)
  set("@keyword.modifier", c.keyword)
  set("@keyword.repeat", c.keyword)
  set("@keyword.return", c.keyword)
  set("@keyword.exception", c.keyword)
  set("@keyword.conditional", c.keyword)
  set("@keyword.directive", c.directive)
  set("@keyword.directive.define", c.directive)
  set("@punctuation", c.syntax)
  set("@punctuation.delimiter", c.syntax)
  set("@punctuation.bracket", c.syntax)
  set("@punctuation.special", c.syntax)
  set("@tag", c.tag)
  set("@tag.attribute", c.property)

  -- LSP semantic tokens otherwise override the corrected Tree-sitter colors.
  set("@lsp.type.variable", c.syntax)
  set("@lsp.type.parameter", c.syntax)
  set("@lsp.type.property", c.property)
  set("@lsp.type.enumMember", c.constant)
  set("@lsp.type.function", c.func)
  set("@lsp.type.method", c.func)
  set("@lsp.type.macro", c.directive)
  set("@lsp.type.decorator", c.directive)
  set("@lsp.type.namespace", c.type)
  set("@lsp.type.class", c.class)
  set("@lsp.type.interface", c.type)
  set("@lsp.type.type", c.type)
  set("@lsp.type.typeParameter", c.type)
  set("@lsp.type.keyword", c.keyword)
  set("@lsp.type.operator", c.syntax)
  set("@lsp.type.string", c.string)
  set("@lsp.type.number", c.number)
end

return M
