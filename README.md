<div align="center">

<h1>shelllock-macos</h1>
<p><i><b>Protect any shell command behind Touch ID 🔐</b></i></p>

[![Github][github]][github-url]
[![Homebrew][homebrew]][homebrew-url]

</div>

<br/>

## About

Gate any shell command or script behind biometric auth. **AI agents cannot bypass this** - they can't physically touch your fingerprint sensor.

```
you type: shelllock ./deploy.sh
           ↓
Touch ID prompt appears
           ↓
✓ authenticated → script runs
✗ failed → nothing happens
```

**Use cases:**
- Protect deploy scripts from eager AI agents
- Gate destructive commands (`rm -rf`, `git push --force`)
- Secure sensitive operations (DB migrations, prod access)

<br/>

## Install

```bash
brew tap vdutts7/tap
brew install shelllock
```

### From source

```bash
git clone https://github.com/vdutts7/shelllock-macos.git
cd shelllock-macos
make install
```

<br/>

## Usage

```bash
# Basic - run script behind Touch ID
shelllock ./deploy.sh

# Custom prompt message
shelllock -m "Deploy to production?" ./deploy.sh

# Inline command
shelllock -c "npm run build && npm test"

# Any command with args
shelllock make install PREFIX=/usr/local
```

<br/>

## Why?

AI coding assistants (Cursor, Copilot, etc.) can execute shell commands. They might accidentally run:
- `./deploy.sh` when you just wanted to review it
- `git push --force` when debugging
- Destructive commands while "fixing" things

**shelllock makes this impossible.** The AI would need to physically touch your fingerprint sensor.

```bash
# In your deploy.sh, add at the top:
#!/bin/bash
if [[ "${SHELLLOCK_VERIFIED:-}" != "1" ]]; then
    exec shelllock -m "Deploy to production?" "$0" "$@"
fi
# ... rest of deploy script
```

Or just always invoke via shelllock:
```bash
alias deploy="shelllock ./deploy.sh"
```

<br/>

## Related

- [applock-macos](https://github.com/vdutts7/applock-macos) - Touch ID gate for `.app` bundles

<br/>

## License

MIT

---

[github]: https://img.shields.io/badge/github-vdutts7-black?logo=github
[github-url]: https://github.com/vdutts7/shelllock-macos
[homebrew]: https://img.shields.io/badge/homebrew-shelllock-orange?logo=homebrew
[homebrew-url]: https://github.com/vdutts7/homebrew-tap
