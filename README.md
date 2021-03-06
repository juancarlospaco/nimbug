# NimBug

- [Nim](https://nim-lang.org) Semi-Auto Bug Report Tool.

![](https://raw.githubusercontent.com/juancarlospaco/nimbug/master/nimbug.png)


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

- **Generates this bug (Fake):** https://github.com/juancarlospaco/nimbug/issues/1
- **Real life use case (Real):** https://github.com/nim-lang/Nim/issues/13722#issue-585682299
- Auto-Detects Git User and Repo of the project you are reporting bugs to.


# Compile-Time options

Define `defaultUser` and `defaultRepo` then you have a custom Bug Report Tool for YOUR project.

**Example:**

- `nim c -d:defaultUser=nim-lang -d:defaultRepo=Nim nimbug.nim`

Now it reports Bugs directly to https://github.com/nim-lang/Nim/issues


# Privacy

- NimBug does not include any path of your personal folders, and you can see the results on the browser anyway.


# See also

- [Conflict-less `changelog.md` generator with configurable categories for Nim, for tiny or massive Git projects.](https://github.com/juancarlospaco/changelogen#changelogen)


# FAQ

- Why?.

I remember Ubuntu years ago come with a tiny script named `ubuntu-bug`.

- Why not use `--title="foo"`?.

The tool is interactive on purpose.

Using all options via arguments will encourage unattended scripts to report bugs.

- Why not use GitHub API?.

Using it from the API offers no benefit over the URL params,
but it requires a valid GitHub Token secret and code to store secrets,
requires OpenSSL with `-d:ssl`, configuration for secrets probably,
documentation about how to setup the secrets on the app before use,
this is what the API takes:

```json
{
  "title": "Found a bug",
  "body": "Can not divide by zero",
  "assignees": [
    "octocat"
  ],
  "labels": [
    "bug"
  ]
}
```

Literally the same you can pass via URL.

But if you want it via API for some reason, I will accept the Pull Request.
