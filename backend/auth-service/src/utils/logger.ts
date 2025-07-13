import chalk from 'chalk';

const logger = {
  info: (message: string, data?: any) => {
    console.log(chalk.blue('ℹ INFO:'), chalk.white(message));
    if (data) console.log(chalk.gray(JSON.stringify(data, null, 2)));
  },

  success: (message: string, data?: any) => {
    console.log(chalk.green('✓ SUCCESS:'), chalk.white(message));
    if (data) console.log(chalk.gray(JSON.stringify(data, null, 2)));
  },

  error: (message: string, error?: any) => {
    console.error(chalk.red('✗ ERROR:'), chalk.white(message));
    if (error) console.error(chalk.red(JSON.stringify(error, null, 2)));
  },

  warn: (message: string, data?: any) => {
    console.warn(chalk.yellow('⚠ WARNING:'), chalk.white(message));
    if (data) console.warn(chalk.gray(JSON.stringify(data, null, 2)));
  },

  request: (method: string, path: string, body?: any) => {
    console.log('\n' + chalk.cyan('==== REQUEST ===='));
    console.log(chalk.yellow('Method:'), chalk.white(method));
    console.log(chalk.yellow('Path:'), chalk.white(path));
    if (body) console.log(chalk.yellow('Body:'), chalk.white(JSON.stringify(body, null, 2)));
    console.log(chalk.cyan('==================\n'));
  },

  response: (status: number, data?: any) => {
    const statusColor = status >= 200 && status < 300 ? 'green' : 'red';
    console.log(chalk[statusColor](`Status: ${status}`));
    if (data) console.log(chalk.gray(JSON.stringify(data, null, 2)));
    console.log(chalk.cyan('==================\n'));
  }
};

export default logger; 