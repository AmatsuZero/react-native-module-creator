const readLine = require("readline").createInterface({
    input: process.stdin,
    output: process.stdout
})
const chalk = require("chalk")
const promiseRetry = require("promise-retry")
const Config = require("./config")

const config = new Config()

const name = () => promiseRetry(retry => {
    const func = () => new Promise((resolve, reject) => {
        readLine.question(`${chalk.yellow("创建的包名")}：`, value => {
            try {
                readLine.write(chalk.gray.bold("查询中..."))
                config.name = value
                readLine.clearLine()
                readLine.write(chalk.gray.bold("包名可用"))
                return resolve(value)
            } catch (e) {
                readLine.clearLine()
                console.warn(chalk.red.bold(e.message))
                return reject(e)
            }
        })
    })
    return func().catch(retry)
})

const type = () => promiseRetry(retry => {
    const func = () => new Promise((resolve, reject) => {
        readLine.question(`${chalk.yellow("创建哪个平台的Package")} (${chalk.underline.blue.bgRed.bold("All")}/${chalk.blue.bold("iOS")}/${chalk.blue.bold("Android")})：`, type => {
            try {
                config.type = type
                return resolve(type)
            } catch (e) {
                console.warn(chalk.red.bold(e.message))
                return reject(e)
            }
        })
    })
    return func().catch(retry)
})

const ios = () => promiseRetry(retry => {
    const func = () => new Promise((resolve, reject) => {
        readLine.question(`${chalk.yellow("选择iOS平台所用语言")} (${chalk.underline.blue.bgRed.bold("Objective-C")}/${chalk.blue.bold("Swift")})：`, type => {
            try {
                config.iOS = type
                return resolve(type)
            } catch (e) {
                console.warn(chalk.red.bold(e.message))
                return reject(e)
            }
        })
    })
    return func().catch(retry)
})

const android = () => promiseRetry(retry => {
    const func = () => new Promise((resolve, reject) => {
        readLine.question(`${chalk.yellow("选择Android平台所用语言")} (${chalk.underline.blue.bgRed.bold("Java")}/${chalk.blue.bold("Kotlin")})：`, type => {
            try {
                config.Android = type
                return resolve(type)
            } catch (e) {
                console.warn(chalk.red.bold(e.message))
                return reject(e)
            }
        })
    })
    return func().catch(retry)
})

const path = () => promiseRetry(retry => {
    const func = () => new Promise((resolve, reject) => {
        readLine.question(`${chalk.yellow("选择创建路径")}：`, type => {
            try {
                config.path = type
                return resolve(type)
            } catch (e) {
                console.warn(chalk.red.bold(e.message))
                return reject(e)
            }
        })
    })
    return func().catch(retry)
})

const confirm = () => new Promise((resolve, reject) => {
    readLine.clearLine()
    readLine.question(`${chalk.yellow("是否确认？")} (${chalk.underline.blue.bgRed.bold("true")}/${chalk.blue.bold("false")})：`, ret => {
        if (ret === "true") {
            readLine.close()
            resolve(config)
        } else {
            readLine.clearLine()
            reject(new Error("用户拒绝"))
        }
    })
})

module.exports = () => name()
    .then(() => {
        readLine.clearLine()
        return type()
    })
    .then(() => {
        switch (config.type) {
            case "ios":
                return ios()
            case "android":
                return android()
            default:
                return ios().then(() => android())
        }
    })
    .then(() => path())
    .then(() => {
        readLine.write(config.description)
        return confirm()
    })

