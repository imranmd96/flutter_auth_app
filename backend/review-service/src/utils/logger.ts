import chalk from 'chalk';

type ChalkColor = 'bgBlue' | 'bgGreen' | 'bgRed' | 'bgYellow' | 'bgGray' | 'bgCyan' | 'bgMagenta';

export class Logger {
  static info(message: string) {
    this.logBoxTable('INFO', 'OK', [{ label: 'Message', value: message }]);
  }

  static success(message: string) {
    this.logBoxTable('SUCCESS', 'OK', [{ label: 'Message', value: message }]);
  }

  static error(message: string, error?: any) {
    const rows = [{ label: 'Message', value: message }];
    if (error) {
      rows.push({ label: 'Stack', value: error.stack || error.toString() });
    }
    this.logBoxTable('ERROR', 'FAILED', rows);
  }

  static warn(message: string) {
    this.logBoxTable('WARNING', 'ATTENTION', [{ label: 'Message', value: message }]);
  }

  static debug(message: string) {
    if (process.env.NODE_ENV === 'development') {
      this.logBoxTable('DEBUG', 'DEV', [{ label: 'Message', value: message }]);
    }
  }

  static request(method: string, path: string, status: number) {
    const statusText = status < 400 ? 'OK' : status < 500 ? 'WARNING' : 'ERROR';
    this.logBoxTable(
      'REQUEST',
      statusText,
      [
        { label: 'Method', value: method },
        { label: 'Path', value: path },
        { label: 'Status', value: status.toString() }
      ]
    );
  }

  static serviceStatus(port: number, env: string) {
    this.logBoxTable(
      'REVIEW SERVICE',
      'ONLINE',
      [
        { label: 'Port', value: port.toString() },
        { label: 'Environment', value: env }
      ],
      {
        urlMessage: 'API URL',
        urlValue: `http://localhost:${port}`
      }
    );
  }

  static analyticsInfo(restaurantId: string, metrics: { [key: string]: number }) {
    const rows = [
      { label: 'Restaurant ID', value: restaurantId },
      ...Object.entries(metrics).map(([key, value]) => ({
        label: key.charAt(0).toUpperCase() + key.slice(1),
        value: value.toString()
      }))
    ];
    this.logBoxTable('ANALYTICS', 'DATA', rows);
  }

  private static logBoxTable(
    title: string,
    status: string,
    rows: { label: string; value: string }[],
    options?: {
      urlMessage?: string;
      urlValue?: string;
    }
  ): void {
    // Calculate the padding needed based on the longest value
    const longestValue = Math.max(...rows.map(row => row.value.length));
    const padding = Math.max(28, longestValue + 2); // Minimum 28 chars, or longer if needed
    
    // Title bar with appropriate colors
    const titleColor = this.getTitleColor(title);
    console.log('\n');
    console.log(chalk[titleColor].white.bold(` ${title} `) + ' ' + chalk.bgGreen.black(` ${status} `));
    
    // Box-style status info
    console.log(chalk.blue('┌────────────────────────────────────────┐'));
    
    // Content rows
    rows.forEach(({ label, value }) => {
      console.log(
        `${chalk.blue('│')} ${chalk.yellow.bold(label)}:      ${chalk.cyan.bold(value.padEnd(padding))} ${chalk.blue('│')}`
      );
    });
    
    // Bottom border
    console.log(chalk.blue('└────────────────────────────────────────┘'));
    
    // URL indicator (if provided)
    if (options?.urlMessage && options?.urlValue) {
      console.log(chalk.bgBlue.white.bold(` ${options.urlMessage}: ${options.urlValue} `));
    }
    
    console.log('\n');
  }

  private static getTitleColor(title: string): ChalkColor {
    switch (title) {
      case 'INFO':
        return 'bgBlue';
      case 'SUCCESS':
        return 'bgGreen';
      case 'ERROR':
        return 'bgRed';
      case 'WARNING':
        return 'bgYellow';
      case 'DEBUG':
        return 'bgGray';
      case 'REQUEST':
        return 'bgCyan';
      case 'REVIEW SERVICE':
        return 'bgMagenta';
      case 'ANALYTICS':
        return 'bgBlue';
      default:
        return 'bgBlue';
    }
  }
} 