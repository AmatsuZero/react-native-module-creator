const xml = require("xmldoc")
const fs = require("fs")

module.exports = manifestPath => new xml.XmlDocument(fs.readFileSync(manifestPath, 'utf8'))
