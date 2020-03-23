# NimBug

- [Nim](https://nim-lang.org) Semi-Auto Bug Report Tool.


# Install

- `nimble install nimbug` (No dependencies)


# Use

```console
$ nimbug

GitHub Username or Team of the project?: juancarlospaco
GitHub Repository of the project?: nimbug
Issue report short and descriptive Title? (Must not be empty): Can not divide by zero
Issue report proposed Labels? (Comma separated, can be empty): bug,invalid
Issue report 1 proposed Assignee? (GitHub User, can be empty): juancarlospaco
Links with useful info/pastebin?  (9 Links max, can be empty): https://nim-lang.org
Links with useful info/pastebin?  (9 Links max, can be empty):

```

- **Result:** https://github.com/juancarlospaco/nimbug/issues/1


# Compile-Time options

Define `defaultUser` and `defaultRepo` then you have a custom Bug Report Tool for YOUR project.

**Example:**

- `nim c -d:defaultUser=nim-lang -d:defaultRepo=Nim nimbug.nim`

Now it reports Bugs directly to https://github.com/nim-lang/Nim/issues


# Web Scraping

- For easy web scraping, search for `<!--NIMBUG_START-->` and `<!--NIMBUG_END-->`, valid JSON should be inside.


# Privacy

NimBug does not include any path of your personal folders, and you can see the results on the browser anyway,
so use it and dont worry, no one will know about your `~/Hentai-Downloader/` ;P


# FAQ

- Why?.

I remember Ubuntu years ago come with a tiny script named `ubuntu-bug`.

- Why not use `--title="foo"`?.

The tool is interactive on purpose.

Using all options via arguments will encourage unattended scripts to report bugs.
