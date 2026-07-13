// PI
import {type ExtensionAPI} from '@earendil-works/pi-coding-agent';

// EXTENSIONS
import {ScopedContext} from './scoped-context/scoped-context.ts';
import {AutoFormat} from './autoformat/autoformat.ts';
import {PermissionGate} from './permission/gate.ts';

export default function (pi: ExtensionAPI): void {
    PermissionGate.register(pi);
    AutoFormat.register(pi);
    ScopedContext.register(pi);
}
