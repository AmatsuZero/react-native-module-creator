const fs = require("fs")
const path = require("path")

module.exports = folder => {
    const flat = 'android'
    const nested = path.join(flat, 'app')
    if (fs.existsSync(path.parse(folder, nested)))
        return nested
    if (fs.existsSync(path.join(folder, flat)))
        return flat
    return null
}
