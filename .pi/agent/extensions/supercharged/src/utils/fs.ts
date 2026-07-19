import {getAgentDir} from '@earendil-works/pi-coding-agent';
import {join} from 'node:path';

export function getExtensionsDir(): string {
    return join(getAgentDir(), 'extensions', 'supercharged');
}
