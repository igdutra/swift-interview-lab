// ============================================================
// node-shims.d.ts — minimal ambient typings for the Node built-ins
// this toolchain uses. Hand-written on purpose: the toolchain is
// zero-dependency (no npm install, no @types/node), and these few
// declarations are all the surface we touch. Node 24 provides the
// real implementations at runtime via type stripping.
// ============================================================

declare interface NodeBuffer {
  readonly length: number;
}

declare module "node:fs" {
  export interface DirectoryEntry {
    name: string;
    isDirectory(): boolean;
  }
  export function readFileSync(path: string, encoding: "utf8"): string;
  export function readFileSync(path: string): NodeBuffer;
  export function writeFileSync(path: string, contents: string): void;
  export function readdirSync(path: string, options: { withFileTypes: true }): DirectoryEntry[];
  export function existsSync(path: string): boolean;
  export function statSync(path: string): { isDirectory(): boolean; isFile(): boolean };
  export function unlinkSync(path: string): void;
}

declare module "node:path" {
  export function join(...segments: string[]): string;
  export function dirname(path: string): string;
  export function resolve(...segments: string[]): string;
  export function extname(path: string): string;
  export function normalize(path: string): string;
}

declare module "node:url" {
  export function fileURLToPath(url: string): string;
}

declare module "node:http" {
  export interface IncomingRequest {
    url?: string;
    method?: string;
  }
  export interface ServerResponse {
    statusCode: number;
    setHeader(name: string, value: string): void;
    end(body?: string | NodeBuffer): void;
  }
  export interface Server {
    listen(port: number, callback?: () => void): void;
  }
  export function createServer(handler: (request: IncomingRequest, response: ServerResponse) => void): Server;
}

declare const process: {
  argv: string[];
  exitCode: number | undefined;
  exit(code?: number): never;
  cwd(): string;
};

declare const console: {
  log(...values: unknown[]): void;
  error(...values: unknown[]): void;
  warn(...values: unknown[]): void;
};

declare interface ImportMeta {
  url: string;
}
