import Schema from 'typebox/schema';
import Type from 'typebox';

export const PermissionActionSchema = Type.Union([
    Type.Literal('allow'),
    Type.Literal('deny'),
    Type.Literal('ask'),
]);

export type PermissionAction = Type.Static<typeof PermissionActionSchema>;

export const RuleTypeSchema = Type.Union([Type.Literal('tool'), Type.Literal('path')]);
export type RuleType = Type.Static<typeof RuleTypeSchema>;

export const ToolNameSchema = Type.Union([
    Type.Literal('read'),
    Type.Literal('bash'),
    Type.Literal('edit'),
    Type.Literal('write'),
    Type.Literal('grep'),
    Type.Literal('find'),
    Type.Literal('ls'),
]);

export type ToolName = Type.Static<typeof ToolNameSchema>;

export const PermissionRuleConfigSchema = Type.Object({
    type: RuleTypeSchema,
    name: Type.Optional(ToolNameSchema),
    agent: Type.Optional(Type.String()),
    pattern: Type.String(),
    action: PermissionActionSchema,
    reason: Type.Optional(Type.String()),
});

export type PermissionRuleConfig = Type.Static<typeof PermissionRuleConfigSchema>;

export const PermissionConfigSchema = Type.Object({
    rules: Type.Array(PermissionRuleConfigSchema),
});

export const PermissionConfigValidator = Schema.Compile(PermissionConfigSchema);

export type PermissionConfig = Type.Static<typeof PermissionConfigSchema>;
