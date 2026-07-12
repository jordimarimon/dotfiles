// Action that should be done when the rule matches
export type PermissionAction = 'allow' | 'deny' | 'ask';

export type RuleType = 'tool' | 'path' | 'bash';

export interface PermissionRuleConfig {
    type: RuleType;
    name?: string; // tool name
    pattern: string;
    action: PermissionAction;
    reason?: string;
}

export interface PermissionConfig {
    rules: PermissionRuleConfig[];
}

export interface PermissionCheckResult {
    action: PermissionAction;
    rule?: PermissionRuleConfig;
    reason?: string;
}

export interface AccessIntent {
    toolName?: string | undefined;
    input: unknown;
    path: string;
    bashCommand?: string | undefined;
}
