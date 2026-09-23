describe("slugify", () => {
  it("no assertion", () => {
    slugify("Hello");
  });

  it("weak only", () => {
    const out = parse("x");
    expect(out).toBeDefined();
    expect(() => parse("x")).not.toThrow();
  });

  it("strong", () => {
    expect(slugify("Hello, World!")).toBe("hello-world");
  });

  test("mock only", () => {
    expect(save).toHaveBeenCalled();
  });
});
