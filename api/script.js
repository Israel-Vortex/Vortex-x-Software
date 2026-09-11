const fs = require("fs");
const path = require("path");

const TOKEN = process.env.SCRIPT_TOKEN || "vx7k2m9gold";

function readScript() {
  if (process.env.SCRIPT_SOURCE && process.env.SCRIPT_SOURCE.length > 30) {
    return process.env.SCRIPT_SOURCE;
  }
  const candidates = [
    path.join(process.cwd(), "private", "script.lua"),
    path.join(__dirname, "..", "private", "script.lua"),
    path.join(__dirname, "script.lua"),
    path.join("/var/task", "private", "script.lua"),
  ];
  for (const p of candidates) {
    try {
      if (fs.existsSync(p)) {
        const data = fs.readFileSync(p, "utf8");
        if (data && data.length > 30) return data;
      }
    } catch (_) {}
  }
  return null;
}

module.exports = function handler(req, res) {
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Content-Type", "text/plain; charset=utf-8");
  res.setHeader("Access-Control-Allow-Origin", "*");

  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  const token = String((req.query && req.query.t) || "");
  if (token !== TOKEN) {
    return res.status(403).send("-- forbidden: token invalido");
  }

  const source = readScript();
  if (!source) {
    return res.status(500).send("-- empty script: falta private/script.lua");
  }

  return res.status(200).send(source);
};