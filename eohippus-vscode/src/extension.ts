import * as portfinder from 'portfinder';
import { ExtensionContext, ExtensionMode, workspace } from 'vscode';
import { Executable, LanguageClient, LanguageClientOptions, ServerOptions, TransportKind } from 'vscode-languageclient/node';

let client: LanguageClient;

export async function activate(context: ExtensionContext) {
	console.log('Activated "eohippus-vscode".');

	const serverPath = getServerPath(context);
	let serverPort = 63421;
	portfinder.getPort({
		port: 49152,
		stopPort: 65535
	}, (err, port) => {
		if (err) {
			console.error(`portfinder couldn't find an ephemeral port; falling back to ${serverPort}`);
		} else {
			serverPort = port;
			console.log(`eohippus-vscode using port ${serverPort}`);
		}
	});

	const serverRunOptions: Executable = {
		command: serverPath,
		transport: {
			kind: TransportKind.socket,
			port: serverPort
		}
	};

	const serverOptions: ServerOptions = {
		run: serverRunOptions,
		debug: serverRunOptions
	};

	const clientOptions: LanguageClientOptions = {
		documentSelector: [
			{
				scheme: 'file',
				language: 'pony'
			}
		],
		synchronize: {
			fileEvents: workspace.createFileSystemWatcher('**/*.pony')
		}
	};

	let client = new LanguageClient('eohippus-lsp', 'Eohippus Pony Language Server', serverOptions, clientOptions);
	client.start();
}

// This method is called when your extension is deactivated
export function deactivate(): Thenable<void> | undefined {
	if (client) {
		return client.stop();
	} else {
		return undefined;
	}
}

function getServerPath(context: ExtensionContext): string {
	let serverPath = context.extensionMode === ExtensionMode.Development
		? context.asAbsolutePath('../build/debug/eohippus-lsp')
		: context.asAbsolutePath('./out/eohippus-lsp-' + process.platform);
	if (process.platform === 'win32') {
		serverPath += '.exe';
	}
	return serverPath;
}
