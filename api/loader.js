/**
 * GET /api/loader
 * Siempre devuelve Lua (compatible con todos los ejecutores).
 */
module.exports = function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Content-Type", "text/plain; charset=utf-8");

  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  const host = req.headers["x-forwarded-host"] || req.headers.host || "vortex-x-sage.vercel.app";
  const proto = req.headers["x-forwarded-proto"] || "https";
  const base = `\( {proto}:// \){host}`;

  const TOKEN = process.env.SCRIPT_TOKEN || "vx7k2m9gold";

  const lua = `-- Vortex X Sage Loader
local ok, src = pcall(function()
  return game:HttpGet("\( {base}/api/script?t= \){TOKEN}")
end)
if not ok or type(src) \~= "string" or #src < 20 then
  return warn("[Vortex] No se pudo cargar el script")
end
if src:sub(1, 2) == "--" and (src:find("forbidden") or src:find("Browser") or src:find("empty")) then
  return warn("[Vortex] " .. src:sub(1, 120))
end
local fn, err = loadstring(src)
if not fn then
  return warn("[Vortex] loadstring: " .. tostring(err))
end
fn()
`;

  return res.status(200).send(lua);
};
