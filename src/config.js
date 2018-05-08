const fs = require("fs")
const path = require("path")
const spawnSync = require("child_process").spawnSync
const chalk = require("chalk")

class Config {

    constructor() {
        this._type = "all"
        this._ios = "objective-c"
        this._android = "java"
        this._path = null
        this._name = null
    }

    get name() {
        return this._name
    }

    set name(value) {
        if (this._name === value) return
        const reg = /^(?!\.)[^\\\/:\*\?"<>\|]{1,255}$/
        if (value.length === 0 || !reg.test(value))
            throw new Error("不合法的文件名")
        else {
            // 检索是否已经有该名称的包
            const error = spawnSync("npm", ["info", value]).stderr
            if(error.length === 0)
                throw new Error("包名已存在，请换另一个名称")
        }
        this._name = value
    }

    get type() {
        return this._type
    }

    set type(value) {
        const type = value.toLowerCase()
        switch (type) {
            case "all":
            case "ios":
            case "android":
                this._type = type
                break
            default:
                throw new Error("不合法的输入")
        }
    }
    get iOS() {
        if (this._type === "android")
            throw new Error("不支持的平台")
        return this._ios
    }
    set iOS(value) {
        if (this._type === "android")
            throw new Error("不支持的平台")
        const type = value.toLowerCase()
        switch (type) {
            case "objective-c":
            case "swift":
                this._ios = type
                break
            default:
                throw new Error("不合法的输入")
        }
    }

    get Android() {
        if (this._type === "ios")
            throw new Error("不支持的平台")
        return this._android
    }

    set Android(value) {
        if (this._type === "ios")
            throw new Error("不支持的平台")
        const type = value.toLowerCase()
        switch (type) {
            case "java":
            case "kotlin":
                this._android = type
                break
            default:
                throw new Error("不合法的输入")
        }
    }

    get path() {
        if (this.name.length === 0)
            throw new Error("请先指定项目名")
        return path.join(this._path, this.name)
    }

    set path(value) {
        if (this._path === value) return
        this._path = value
        if (fs.existsSync(this.path)) {
            const stats = fs.statSync(this.path)
            if (!stats.isDirectory()) {
                this._path = null
                throw new Error("该路径不是一个文件夹")
            }
        }
    }

    get description() {
        let desc = `
        ${chalk.green("包名")}: ${this.name}
        ${chalk.green("类型")}: ${this.type}
        ${chalk.green("保存路径")}: ${this.path}
        ${chalk.green("所用语言")}:
        `
        switch (this.type) {
            case "all":
                desc += `
          ${chalk.green("iOS")}: ${this.iOS}
          ${chalk.green("Android")}: ${this.Android}
                `
                break
            case "ios":
                desc += ` ${chalk.green("iOS")}: ${this.iOS}`
                break
            case "android":
                desc += ` ${chalk.green("Android")}: ${this.Android}`
                break
            default:
                break
        }
        return desc
    }
}

module.exports = Config
