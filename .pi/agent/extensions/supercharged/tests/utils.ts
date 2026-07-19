type PartialDeep<T> = T extends (...args: unknown[]) => unknown
    ? PartialDeepObject<T> | undefined
    : T extends object
      ? T extends readonly (infer ItemType)[] // Test for arrays/tuples
          ? ItemType[] extends T // Test for arrays (non-tuples) specifically
              ? readonly ItemType[] extends T // Differentiate readonly and mutable arrays
                  ? readonly PartialDeep<ItemType | undefined>[]
                  : PartialDeep<ItemType | undefined>[]
              : PartialDeepObject<T> // Tuples behave properly
          : PartialDeepObject<T>
      : T;

type PartialDeepObject<ObjectType extends object> = {
    [KeyType in keyof ObjectType]?: PartialDeep<ObjectType[KeyType]>;
};

export function fromPartial<T>(mock: PartialDeep<NoInfer<T>>): T {
    return mock as T;
}
