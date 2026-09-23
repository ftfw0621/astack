# fixture runners for tests/run.sh
ok:
  command: cd {cwd} && cat {prompt} > {out} && echo "model={model} effort={effort}" >> {out}
quota:
  command: cd {cwd} && echo "Error: rate_limit_exceeded, insufficient_quota" >&2 && exit 1
  unavailable: rate.?limit|insufficient_quota
crash:
  command: cd {cwd} && echo "segfault" >&2 && exit 139
  unavailable: rate.?limit
slow:
  command: cd {cwd} && sleep 5 && echo late > {out}
empty:
  command: cd {cwd} && true
stdout-only:
  command: cd {cwd} && echo "answer on stdout"
native:
  host: claude-code
