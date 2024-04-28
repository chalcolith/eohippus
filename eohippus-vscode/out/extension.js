"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivate = exports.activate = void 0;
const portfinder = __importStar(require("portfinder"));
const vscode_1 = require("vscode");
const node_1 = require("vscode-languageclient/node");
let client;
async function activate(context) {
    console.log('Activated "eohippus-vscode".');
    const serverPath = getServerPath(context);
    let serverPort = 63421;
    portfinder.getPort({
        port: 49152,
        stopPort: 65535
    }, (err, port) => {
        if (err) {
            console.error(`portfinder couldn't find an ephemeral port; falling back to ${serverPort}`);
        }
        else {
            serverPort = port;
            console.log(`eohippus-vscode using port ${serverPort}`);
        }
    });
    const serverRunOptions = {
        command: serverPath,
        transport: {
            kind: node_1.TransportKind.socket,
            port: serverPort
        }
    };
    const serverOptions = {
        run: serverRunOptions,
        debug: serverRunOptions
    };
    const clientOptions = {
        documentSelector: [
            {
                scheme: 'file',
                language: 'pony'
            }
        ],
        synchronize: {
            fileEvents: vscode_1.workspace.createFileSystemWatcher('**/*.pony')
        }
    };
    let client = new node_1.LanguageClient('eohippus-lsp', 'Eohippus Pony Language Server', serverOptions, clientOptions);
    client.start();
}
exports.activate = activate;
// This method is called when your extension is deactivated
function deactivate() {
    if (client) {
        return client.stop();
    }
    else {
        return undefined;
    }
}
exports.deactivate = deactivate;
function getServerPath(context) {
    let serverPath = context.extensionMode === vscode_1.ExtensionMode.Development
        ? context.asAbsolutePath('../build/debug/eohippus-lsp')
        : context.asAbsolutePath('./out/eohippus-lsp-' + process.platform);
    if (process.platform === 'win32') {
        serverPath += '.exe';
    }
    return serverPath;
}
//# sourceMappingURL=extension.js.map