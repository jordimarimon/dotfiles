// PI
import {type ExtensionAPI} from '@earendil-works/pi-coding-agent';

// EXTENSIONS
import {PermissionGate} from './permission/gate.ts';

export default function (pi: ExtensionAPI): void {
    PermissionGate.register(pi);
}
