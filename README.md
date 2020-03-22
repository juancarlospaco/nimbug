# NimBug

- [Nim](https://nim-lang.org) Semi-Auto Bug Report Tool.


# Install

- `nimble install nimbug` (No dependencies)


# Use

```console
$ nimbug

GitHub Username or Team of the project?: juancarlospaco
GitHub Repo of the project?: nimbug
Issue report short Title? (Must not be empty): Can not divide by zero
Issue report proposed Labels? (Comma separated, can be empty): bug, invalid
Issue report proposed Assignee? (GitHub Username, can be empty): juancarlospaco
Links with useful information? (Can be empty): https://nim-lang.org
Links with useful information? (Can be empty):

```

- **Result:** https://github.com/juancarlospaco/nimbug/issues/1


# Compile-Time options

Define `defaultUser` and `defaultRepo` then you have a custom Bug Report Tool for YOUR project.

**Example:**

- `nim c -d:defaultUser=nim-lang -d:defaultRepo=Nim nimbug.nim`

Now it reports Bugs directly to https://github.com/nim-lang/Nim/issues


# FAQ

- Why?.

I remember Ubuntu years ago come with a tiny script named `ubuntu-bug`.

- Why not use `--title="foo"`?.

The tool is interactive on purpose.

Using all options via arguments will encourage unattended scripts to report bugs.
