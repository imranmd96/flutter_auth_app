"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const colors = {
    reset: '\x1b[0m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m',
    white: '\x1b[37m',
    black: '\x1b[30m',
    bgRed: '\x1b[41m',
    bgGreen: '\x1b[42m',
    bgBlue: '\x1b[44m',
    bgYellow: '\x1b[43m',
    bgMagenta: '\x1b[45m',
    bgCyan: '\x1b[46m',
    bgWhite: '\x1b[47m',
    bgBlack: '\x1b[40m',
    bold: '\x1b[1m',
    dim: '\x1b[2m',
    italic: '\x1b[3m',
    underline: '\x1b[4m'
};
const createColorFunction = (colorCode) => {
    return (text) => `${colorCode}${text}${colors.reset}`;
};
const chalk = {
    red: createColorFunction(colors.red),
    green: createColorFunction(colors.green),
    yellow: createColorFunction(colors.yellow),
    blue: createColorFunction(colors.blue),
    magenta: createColorFunction(colors.magenta),
    cyan: createColorFunction(colors.cyan),
    white: createColorFunction(colors.white),
    black: createColorFunction(colors.black),
    bgRed: createColorFunction(colors.bgRed),
    bgGreen: createColorFunction(colors.bgGreen),
    bgBlue: createColorFunction(colors.bgBlue),
    bgYellow: createColorFunction(colors.bgYellow),
    bgMagenta: createColorFunction(colors.bgMagenta),
    bgCyan: createColorFunction(colors.bgCyan),
    bgWhite: createColorFunction(colors.bgWhite),
    bgBlack: createColorFunction(colors.bgBlack),
    bold: createColorFunction(colors.bold),
    dim: createColorFunction(colors.dim),
    italic: createColorFunction(colors.italic),
    underline: createColorFunction(colors.underline)
};
exports.default = chalk;
//# sourceMappingURL=chalk-wrapper.js.map