local M = {}

-- Canvas matches Ghostty's terminal backgrounds.
local canvas = {
  dark = "#141414",
  light = "#f3f3f3",
}

-- Syntax defaults match Cursor 3.16.26. At runtime token and semantic colors
-- are read from Cursor.app, which remains the source of truth after updates.
local defaults = {
  dark = {
    background = canvas.dark,
    cursor = "#F0F0F0",
    syntax = "#D6D6DD",
    keyword = "#82D2CE",
    language_variable = "#CC7C8A",
    self_parameter = "#CC7C8A",
    constant = "#D6D6DD",
    builtin_constant = "#82D2CE",
    default_library = "#D6D6DD",
    global_variable = "#A8CC7C",
    number = "#EBC88D",
    func = "#EFB080",
    func_call = "#EBC88D",
    func_builtin = "#82D2CE",
    func_bold = true,
    comment = "#989898",
    comment_italic = true,
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
    self_parameter = "#92156A",
    constant = "#005293",
    builtin_constant = "#005293",
    default_library = "#3B7E84",
    global_variable = "#007041",
    number = "#92156A",
    func = "#CD4500",
    func_call = "#CD4500",
    func_builtin = "#3B7E84",
    func_bold = false,
    comment = "#6B6B6B",
    comment_italic = true,
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

local function parse_hex(color)
  if type(color) ~= "string" then
    return nil
  end

  local hex = color:gsub("^#", "")
  if #hex == 3 then
    hex = hex:sub(1, 1):rep(2) .. hex:sub(2, 2):rep(2) .. hex:sub(3, 3):rep(2)
  end
  if #hex ~= 6 and #hex ~= 8 then
    return nil
  end

  return {
    r = tonumber(hex:sub(1, 2), 16),
    g = tonumber(hex:sub(3, 4), 16),
    b = tonumber(hex:sub(5, 6), 16),
    a = #hex == 8 and tonumber(hex:sub(7, 8), 16) / 255 or 1,
  }
end

local function composite_hex(foreground, background)
  local fg = parse_hex(foreground)
  if not fg then
    return foreground
  end
  if fg.a >= 1 then
    return string.format("#%02X%02X%02X", fg.r, fg.g, fg.b)
  end

  local bg = parse_hex(background)
  if not bg then
    return string.format("#%02X%02X%02X", fg.r, fg.g, fg.b)
  end

  return string.format(
    "#%02X%02X%02X",
    math.floor(fg.r * fg.a + bg.r * (1 - fg.a) + 0.5),
    math.floor(fg.g * fg.a + bg.g * (1 - fg.a) + 0.5),
    math.floor(fg.b * fg.a + bg.b * (1 - fg.a) + 0.5)
  )
end

local function has_font_style(settings, style)
  return type(settings) == "table"
    and type(settings.fontStyle) == "string"
    and settings.fontStyle:find(style, 1, true) ~= nil
end

local function token_settings(theme, scope)
  -- Later TextMate rules take precedence when a scope appears more than once.
  for index = #theme.tokenColors, 1, -1 do
    local token = theme.tokenColors[index]
    if token.settings and contains_scope(token.scope, scope) then
      return token.settings
    end
  end
end

local function token_color(theme, scope, fallback)
  local settings = token_settings(theme, scope)
  if settings and settings.foreground then
    return settings.foreground
  end
  return fallback
end

local function semantic_entry(theme, key)
  local tokens = theme.semanticTokenColors
  if type(tokens) ~= "table" then
    return nil
  end

  local value = tokens[key]
  if type(value) == "string" then
    return { foreground = value }
  end
  if type(value) == "table" then
    return value
  end
  return nil
end

local function semantic_color(theme, key, fallback)
  local entry = semantic_entry(theme, key)
  if entry and entry.foreground then
    return entry.foreground
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
  colors.self_parameter = semantic_color(theme, "selfParameter", colors.language_variable)
  colors.constant = token_color(theme, "constant", colors.constant)
  colors.builtin_constant = token_color(theme, "support.constant", colors.builtin_constant)
  colors.default_library = semantic_color(theme, "variable.defaultLibrary", colors.default_library)
  colors.global_scope = composite_hex(
    semantic_color(theme, "variable.defaultLibrary.globalScope", colors.default_library),
    colors.background
  )
  colors.global_variable = semantic_color(theme, "variable.global", colors.global_variable)
  colors.readonly_variable = semantic_color(theme, "variable.readonly", colors.builtin_constant)
  colors.number = token_color(theme, "constant.numeric", colors.number)
  colors.func = token_color(theme, "entity.name.function", colors.func)
  colors.func_call = semantic_color(theme, "function", colors.func_call)
  local func_decl = semantic_entry(theme, "function.declaration")
  if func_decl and func_decl.foreground then
    colors.func = func_decl.foreground
    colors.func_bold = has_font_style(func_decl, "bold")
  end
  colors.func_builtin = semantic_color(theme, "function.builtin", colors.func_builtin)
  local comment = token_settings(theme, "comment")
  if comment and comment.foreground then
    colors.comment = composite_hex(comment.foreground, colors.background)
    colors.comment_italic = has_font_style(comment, "italic")
  end
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
  local func_decl = c.func_bold and { bold = true } or nil
  local comment = c.comment_italic and { italic = true } or nil

  set("Identifier", c.syntax)
  set("Function", c.func, func_decl)
  set("Comment", c.comment, comment)
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
  set("@variable.default_library", c.global_scope)
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
  set("@function", c.func, func_decl)
  set("@function.builtin", c.func_builtin)
  set("@function.call", c.func_call)
  set("@function.method", c.func, func_decl)
  set("@function.method.call", c.func_call)
  set("@function.macro", c.directive)
  set("@comment", c.comment, comment)
  set("@comment.documentation", c.comment, comment)
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
  set("@tag.delimiter", c.syntax)

  -- LSP semantic tokens otherwise override the corrected Tree-sitter colors.
  set("@lsp.type.variable", c.syntax)
  set("@lsp.type.parameter", c.syntax)
  set("@lsp.type.selfParameter", c.self_parameter)
  set("@lsp.type.property", c.property)
  set("@lsp.type.enumMember", c.constant)
  set("@lsp.type.function", c.func_call)
  set("@lsp.type.method", c.func_call)
  set("@lsp.typemod.function.declaration", c.func, func_decl)
  set("@lsp.typemod.function.definition", c.func, func_decl)
  set("@lsp.typemod.function.defaultLibrary", c.func_builtin)
  set("@lsp.typemod.method.declaration", c.func, func_decl)
  set("@lsp.typemod.method.definition", c.func, func_decl)
  set("@lsp.typemod.method.defaultLibrary", c.func_builtin)
  set("@lsp.typemod.variable.constant", c.builtin_constant)
  set("@lsp.typemod.variable.defaultLibrary", c.default_library)
  set("@lsp.typemod.variable.globalScope", c.global_scope)
  set("@lsp.typemod.variable.global", c.global_variable)
  set("@lsp.typemod.variable.readonly", c.readonly_variable)
  set("@lsp.typemod.class.defaultLibrary", c.func_builtin)
  set("@lsp.typemod.class.builtin", c.func_builtin)
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
