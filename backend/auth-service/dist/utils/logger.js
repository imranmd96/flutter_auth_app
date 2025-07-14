"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const chalk_1 = __importDefault(require("chalk"));
const logger = {
    info: (message, data) => {
        console.log(chalk_1.default.blue('ℹ INFO:'), chalk_1.default.white(message));
        if (data)
            console.log(chalk_1.default.gray(JSON.stringify(data, null, 2)));
    },
    success: (message, data) => {
        console.log(chalk_1.default.green('✓ SUCCESS:'), chalk_1.default.white(message));
        if (data)
            console.log(chalk_1.default.gray(JSON.stringify(data, null, 2)));
    },
    error: (message, error) => {
        console.error(chalk_1.default.red('✗ ERROR:'), chalk_1.default.white(message));
        if (error)
            console.error(chalk_1.default.red(JSON.stringify(error, null, 2)));
    },
    warn: (message, data) => {
        console.warn(chalk_1.default.yellow('⚠ WARNING:'), chalk_1.default.white(message));
        if (data)
            console.warn(chalk_1.default.gray(JSON.stringify(data, null, 2)));
    },
    request: (method, path, body) => {
        console.log('\n' + chalk_1.default.cyan('==== REQUEST ===='));
        console.log(chalk_1.default.yellow('Method:'), chalk_1.default.white(method));
        console.log(chalk_1.default.yellow('Path:'), chalk_1.default.white(path));
        if (body)
            console.log(chalk_1.default.yellow('Body:'), chalk_1.default.white(JSON.stringify(body, null, 2)));
        console.log(chalk_1.default.cyan('==================\n'));
    },
    response: (status, data) => {
        const statusColor = status >= 200 && status < 300 ? 'green' : 'red';
        console.log(chalk_1.default[statusColor](`Status: ${status}`));
        if (data)
            console.log(chalk_1.default.gray(JSON.stringify(data, null, 2)));
        console.log(chalk_1.default.cyan('==================\n'));
    }
};
exports.default = logger;
//# sourceMappingURL=logger.js.map