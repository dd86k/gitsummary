# gitsummary

This simple program traverses folders in the current or specified directory
search for git repositories (shallow) and gives a list of recent commits per
project, and is mostly useful for writing periodic recaps.

It was created mainly to motivate myself in multiple ways.

Defaults to 1 month and its output is Markdown compatible.

# Example

```
$ gitsummary
# alicedbg:
- 25 hours ago: cli: Change synopsis
- 26 hours ago: cli: -m to -a
- 6 days ago: Minor CLI update
- 6 days ago: dub: Remove version

# ddcpuid:
- 2 days ago: Update (c) year
- 2 days ago: Bump version 0.21.1
- 2 days ago: AMD supports avx512bf16
- 5 days ago: Support AVX-512 on AMD
- 5 days ago: amd supports la57

```

# License

Under 0-BSD License.