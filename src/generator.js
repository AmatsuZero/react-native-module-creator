const fs = require("fs")
const Path = require("path")
const { spawn } = require("child_process")
const { promisify } = require("util")

const createDir = path => {
    if (fs.existsSync(path)) return
    return new Promise((resolve, reject) => fs.mkdir(path, 0o777, error => {
        if (error)
            reject(error)
        else
            resolve(path)
    }))
}

const createJSON = config => new Promise((resolve, reject) => {
    const packageJSON = {
        name: config.name,
        version: "0.1.0",
        description: "",
        main: "index.js",
        scripts: {
            "test": "echo \"Error: no test specified\" && exit 1"
        },
        author: "",
        license: "ISC"
    }
    try {
        const json = JSON.stringify(packageJSON)
        fs.writeFile(Path.join(config.path, "package.json"), json, err => err ? reject(err) : resolve())
    } catch (e) {
        return reject(e)
    }
})

const exampleGenerator = path => new Promise(((resolve, reject) => {
    const init = spawn("react-native", ["init", "example"], {
        cwd: path
    })
    init.on('close', code => resolve(code))
    init.on('exit', code => resolve(code))
    init.on('error', error => reject(error))
}))

const moduleGenerator = config => new Promise((resolve, reject) => {
    const bridge = spawn("react-native", ["new-module"], {
        cwd: Path.join(__dirname, "../template"),
        stdio: 'pipe',
        removeHistoryDuplicates: true
    })
    bridge.stdout.on('data', value => {
        const question = value.toString()
        if (question.includes("What is your bridge module called?"))
            bridge.stdin.write(config.name + "\n")
        else if (question.includes("What type of bridge would you like to create?"))
            bridge.stdin.write("\n")
        else if (question.includes("What OS & languages would you like to support?")) {
            bridge.stdin.write("\n")
        } else if (question.includes("What directory should we deliver your JS files to?"))
            bridge.stdin.write(config.path + "\n")
    })
    bridge.stderr.on('data', data => console.error(`stderr: ${data}`))
    bridge.on('close', code => resolve(code))
    bridge.on('exit', code => resolve(code))
    bridge.on('error', error => reject(error))
})

const modifyExampleJSON = async (path, name) => {
    const readFile = promisify(fs.readFile)
    const writeFile = promisify(fs.writeFile)
    try {
        const data = await readFile(path, 'utf8')
        const packageJSON = JSON.parse(data)
        const dependencies = packageJSON["dependencies"]
        dependencies[name] = "file:.."
        const jsonStr = JSON.stringify(packageJSON)
        await writeFile(path, jsonStr, 'utf8')
    } catch (e) {
        throw e
    }
}

module.exports = async config => {
    try {
        await createDir(config.path) // 项目目录
        switch (config.type) {
            case "ios":
                await createDir(Path.join(config.path, "ios")) // iOS 目录
                break
            case "android":
                await createDir(Path.join(config.path, "android")) // android 目录
                break
            default:
                await createDir(Path.join(config.path, "ios"))
                await createDir(Path.join(config.path, "android"))
                break
        }
        await createJSON(config)
        // 生成示例项目
        console.log(chalk.black.bgGreenBright.bold("创建示例项目中"))
        await exampleGenerator(config.path)
        console.log(chalk.black.bgGreenBright.bold("创建完毕"))
        // 修改example的package.json
        await modifyExampleJSON(Path.join(config.path, "example"), config.name)
        // 生成对应文件
        await moduleGenerator(config)
    } catch (e) {
        console.error(e)
    }
}
