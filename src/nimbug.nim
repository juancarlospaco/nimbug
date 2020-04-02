import os, osproc, times, browsers, json, strutils, encodings, uri, rdstdin, posix, posix_utils, std/compilesettings

const baseBugTemplate = """# Examples

```nim

```

# Current Output

```nim

```

# Expected Output

```nim

```

# Possible Solution

# Additional Information

"""

template isSsd(): bool =
  when defined(linux): # Returns `true` if main disk is SSD (Solid). Linux only
    try: readFile("/sys/block/sda/queue/rotational") == "0\n" except: false

proc getSystemInfo*(): JsonNode =
  result = %*{
    "compiled": CompileDate & "T" & CompileTime,
    "NimVersion": NimVersion,
    "hostCPU": hostCPU,
    "hostOS": hostOS,
    "cpuEndian": cpuEndian,
    "getTempDir": getTempDir(),
    "now": $now(),
    "getCurrentEncoding": getCurrentEncoding(),
    "getFreeMem": getFreeMem(),
    "getTotalMem": getTotalMem(),
    "getOccupiedMem": getOccupiedMem(),
    "countProcessors": countProcessors(),
    "arch": uname().machine,
    "FileSystemCaseSensitive": FileSystemCaseSensitive,
    "nimcacheDir": querySetting(SingleValueSetting.nimcacheDir),
    "ccompilerPath": querySetting(SingleValueSetting.ccompilerPath),
    "currentCompilerExe": getCurrentCompilerExe(),
    "nimpretty": execCmdEx("nimpretty --version").output.strip,
    "nimble": execCmdEx("nimble --noColor --version").output.strip,
    "nimgrep": execCmdEx("nimgrep --nocolor --version").output.strip,
    "nimsuggest": execCmdEx("nimsuggest --version").output.strip,
    "choosenim": if findExe"choosenim".len > 0: execCmdEx("choosenim --noColor --version").output.strip else: "",
    "gcc": if findExe"gcc".len > 0: execCmdEx("gcc --version").output.splitLines()[0].strip else: "",
    "clang": if findExe"clang".len > 0: execCmdEx("clang --version").output.splitLines()[0].strip else: "",
    "git": if findExe"git".len > 0: execCmdEx("git --version").output.replace("git version", "").strip else: "",
    "node": if findExe"node".len > 0: execCmdEx("node --version").output.strip else: "",
    "python": if findExe"python".len > 0: execCmdEx("python --version").output.replace("Python", "").strip else: "",
    "ssd": isSsd()
  }

proc getUserRepo(): array[2, string] =
  const
    defaultUser {.strdefine.} = "nim-lang"
    defaultRepo {.strdefine.} = "Nim"
    opt3 = gorgeEx"git config --get github.user".output.strip
    opt0 = gorgeEx"git config --get user.name".output.strip
  let
    cmd = execCmdEx"git config --get remote.origin.url"
    opt1 = $getpwuid(getuid()).pw_name
    opt2 = getCurrentDir().extractFilename
    opt6 = getEnv("VIRTUAL_ENV").extractFilename.strip
    opt4 = if cmd.exitCode == 0: cmd.output.strip[19..^5].split("/")[0] else: ""
    opt5 = if cmd.exitCode == 0: cmd.output.strip[19..^5].split("/")[1] else: ""
  echo("Select GitHub User or Team of the project?:\n", "0\t", opt0, "\n1\t",
    opt1, "\n2\t", opt2, "\n3\t", opt3, "\n4\t", opt4, "\n5\t", opt5,
    "\n6\t", opt6, "\n7\t", defaultRepo, "\n8\t", defaultUser, "\n9\tType (Manual)\n")
  let githubUser = case readLineFromStdin(" 0, 1, 2, 3, 4, 5, 6, 7, 8, 9?: ").parseInt
    of 0: opt0
    of 1: opt1
    of 2: opt2
    of 3: opt3
    of 4: opt4
    of 5: opt5
    of 6: opt6
    of 7: defaultRepo
    of 8: defaultUser
    else: readLineFromStdin("GitHub Username or Team of the project?: ").strip
  echo("GitHub Repository of the project?:\n", "0\t", opt0, "\n1\t", opt1,
    "\n2\t", opt2, "\n3\t", opt3, "\n4\t", opt4, "\n5\t", opt5,
    "\n6\t", opt6, "\n7\t", defaultUser, "\n8\t", defaultRepo, "\n9\tType (Manual)\n")
  let githubRepo = case readLineFromStdin(" 0, 1, 2, 3, 4, 5, 6, 7, 8, 9?: ").parseInt
    of 0: opt0
    of 1: opt1
    of 2: opt2
    of 3: opt3
    of 4: opt4
    of 5: opt5
    of 6: opt6
    of 7: defaultUser
    of 8: defaultRepo
    else: readLineFromStdin("GitHub Repository of the project?: ").strip
  when not defined(release): echo [githubUser, githubRepo]
  result = [githubUser, githubRepo]

proc getLink*(user, repo, title, labels, assignee: string, links: seq[string], useTemplate: bool): string =
  let info = getSystemInfo().pretty
  echo "\n", info, "\n"
  var body = if useTemplate: baseBugTemplate else: ""
  body.add("\n\n# System Information\n\n<details>\n\n```json\n\n" & info & "\n```\n\n</details>\n\n")
  if labels.len > 0:
    body.add "# Proposed Labels\n\n```csv\n" & labels & "\n```\n\n"
  if assignee.len > 0:
    body.add "# Proposed Assignee\n\n* <kbd>" & assignee & "</kbd>\n\n"
  if links.len > 0:
    body.add "# Links\n\n"
    for i, url in links: body.add $i & ". " & url & "\n"
    body.add "\n\n"
  result = ("https://github.com/" & user & "/" & repo & "/issues/new?" &
    encodeQuery({"title": title, "labels": labels, "assignee": assignee, "body": body}))

proc reportBug*(user, repo, title, labels, assignee: string, links: seq[string], useTemplate: bool) =
  let linky = getLink(user, repo, title, labels, assignee, links, useTemplate)
  when not defined(release): echo linky
  openDefaultBrowser linky

proc main() =
  let user_repo = getUserRepo()
  var title, link: string
  let useTemplate = readLineFromStdin("Use an 'Issue Report Template' at the top of Bug report? (Y/n): ").normalize == "y"
  while title.len == 0:
    title = readLineFromStdin("Issue report short and descriptive Title? (Must not be empty): ").strip
  let
    labels = readLineFromStdin("Issue report proposed Labels? (Comma separated, can be empty): ").strip
    assignee = readLineFromStdin("Issue report 1 proposed Assignee? (GitHub User, can be empty): ").normalize.strip
  var links = newSeqOfCap[string](9)
  for _ in 1..9:
    link = readLineFromStdin("Links with useful info/pastebin?  (9 Links max, can be empty): ").toLowerAscii.strip
    if link.len == 0: break else: links.add link
  reportBug(user_repo[0], user_repo[1], title, labels, assignee, links, useTemplate)


when isMainModule:
  if paramCount() > 0: quit"NimBug is an interactive tool, run it without arguments"
  main()
