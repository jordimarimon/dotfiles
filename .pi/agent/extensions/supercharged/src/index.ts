// PI
import type {ExtensionAPI} from '@earendil-works/pi-coding-agent';

// EXTENSIONS
import {ScopedContext} from './scoped-context/scoped-context.ts';
import {AutoFormat} from './autoformat/autoformat.ts';
import {PermissionGate} from './permission/gate.ts';
import {ToolIntent} from './utils/intent.ts';

export default function (pi: ExtensionAPI): void {
    // The order of registration is important!
    ToolIntent.register(pi);
    PermissionGate.register(pi);
    AutoFormat.register(pi);
    ScopedContext.register(pi);
}
