export function load(input: unknown) {
  const user = input as User;
  const raw = input as any;
  // @ts-ignore
  const n: any = raw.count;
  // TODO: handle the empty case
  // const old = legacy(input);
  // Step 1: parse the thing
  try {
    save(user);
  } catch (e) {}
  console.log(n);
  if (n) {
    if (user) {
      if (raw) {
        if (input) {
          if (e) {
                    deep();
          }
        }
      }
    }
  }
  return user;
}
