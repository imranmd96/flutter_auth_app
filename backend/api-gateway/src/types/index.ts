export interface ProxyConfig {
  [key: string]: {
    target: string | undefined;
    pathRewrite: {
      [key: string]: string;
    };
  };
} 