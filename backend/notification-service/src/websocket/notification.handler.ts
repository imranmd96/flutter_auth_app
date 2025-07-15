import WebSocket from 'ws';
import { Server } from 'http';
import jwt from 'jsonwebtoken';
import { Notification } from '../models/notification';

interface WebSocketClient extends WebSocket {
  isAlive: boolean;
  userId: string;
}

export class NotificationWebSocket {
  private wss: WebSocket.Server;
  private clients: Map<string, Set<WebSocketClient>>;

  constructor(server: Server) {
    this.wss = new WebSocket.Server({ server, path: '/ws/notifications' });
    this.clients = new Map();
    this.initialize();
  }

  private initialize(): void {
    this.wss.on('connection', this.handleConnection.bind(this));
    this.startHeartbeat();
  }

  private handleConnection(ws: WebSocketClient, req: any): void {
    try {
      const token = req.url.split('token=')[1];
      if (!token) {
        ws.close(1008, 'Authentication required');
        return;
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET || '') as {
        id: string;
      };

      ws.userId = decoded.id;
      ws.isAlive = true;

      // Add client to the map
      if (!this.clients.has(decoded.id)) {
        this.clients.set(decoded.id, new Set());
      }
      this.clients.get(decoded.id)?.add(ws);

      // Handle client messages
      ws.on('message', (message: string) => {
        try {
          const data = JSON.parse(message);
          this.handleMessage(ws, data);
        } catch (error) {
          console.error('Error parsing message:', error);
        }
      });

      // Handle client disconnection
      ws.on('close', () => {
        this.handleDisconnection(ws);
      });

      // Handle pong
      ws.on('pong', () => {
        ws.isAlive = true;
      });

    } catch (error) {
      console.error('WebSocket connection error:', error);
      ws.close(1008, 'Authentication failed');
    }
  }

  private handleMessage(ws: WebSocketClient, data: any): void {
    // Handle different message types
    switch (data.type) {
      case 'subscribe':
        // Handle subscription to specific notification types
        break;
      case 'unsubscribe':
        // Handle unsubscription from specific notification types
        break;
      default:
        console.warn('Unknown message type:', data.type);
    }
  }

  private handleDisconnection(ws: WebSocketClient): void {
    const userClients = this.clients.get(ws.userId);
    if (userClients) {
      userClients.delete(ws);
      if (userClients.size === 0) {
        this.clients.delete(ws.userId);
      }
    }
  }

  private startHeartbeat(): void {
    const interval = setInterval(() => {
      this.wss.clients.forEach((ws: WebSocket) => {
        const client = ws as WebSocketClient;
        if (!client.isAlive) {
          this.handleDisconnection(client);
          return client.terminate();
        }
        client.isAlive = false;
        client.ping();
      });
    }, Number(process.env.WS_HEARTBEAT_INTERVAL) || 30000);

    this.wss.on('close', () => {
      clearInterval(interval);
    });
  }

  public async broadcastNotification(notification: InstanceType<typeof Notification>): Promise<void> {
    const userClients = this.clients.get(notification.recipient.id);
    if (!userClients) return;

    const message = JSON.stringify({
      type: 'notification',
      data: notification
    });

    userClients.forEach((client: WebSocketClient) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  }

  public async broadcastToAll(message: any): Promise<void> {
    const messageStr = JSON.stringify(message);
    this.wss.clients.forEach((ws: WebSocket) => {
      const client = ws as WebSocketClient;
      if (client.readyState === WebSocket.OPEN) {
        client.send(messageStr);
      }
    });
  }
} 