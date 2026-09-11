/**
 * GET /api/script?t=TOKEN
 * Entrega el script. Proteccion = TOKEN (no User-Agent).
 */
const fs = require("fs");
const path = require("path");

const TOKEN = process.env.SCRIPT_TOKEN || "vx7k2m9gold";

module.exports = function handler(req, res) {
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Content-Type", "text/plain; charset=utf-8");
  res.setHeader("X-Robots-Tag", "noindex");
  res.setHeader("Access-Control-Allow-Origin", "*");

  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  const token = (req.query && req.query.t) || "";
  if (token !== TOKEN) {
    return res.status(403).send("-- forbidden: token invalido");
  }

  let source = process.env.SCRIPT_SOURCE || "";

  if (!source) {
    const candidates = [
      path.join(process.cwd(), "private", "script.lua"),
      path.join(__dirname, "..", "private", "script.lua"),
      path.join("/var/task", "private", "script.lua"),
    ];
    for (const p of candidates) {
      try {
        if (fs.existsSync(p)) {
          source = fs.readFileSync(p, "utf8");
          break;
        }
      } catch (_) {}
    }
  }

  if (!source || source.length < 30) {
    return res.status(500).send("-- empty script: sube private/script.lua o define SCRIPT_SOURCE");
  }

  return res.status(200).send(source);
};
