<div align="center">
<img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/terminal.webp" alt="logo" width="80" height="80" />
<img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/apple-touchid.webp" alt="logo" width="80" height="80" />
<h1>shelllock-macos</h1>
<p><i><b>Protect any shell command behind Touch ID 🔐</b></i></p>

[![Github][github]][github-url]
[![Homebrew][homebrew]][homebrew-url]

</div>

<br/>

## Table of Contents

<ol>
  <a href="#about">📝 About</a><br/>
  <a href="#install">💻 Install</a><br/>
  <a href="#usage">🚀 Usage</a><br/>
  <a href="#tools-used">🔧 Tools Used</a><br/>
  <a href="#related">🔗 Related</a><br/>
  <a href="#contact">👤 Contact</a>
</ol>

<br/>

## About

Gate any shell command or script behind biometric auth. **AI agents cannot bypass this** — they can't physically touch your fingerprint sensor.

```
you type: shelllock ./deploy.sh
           ↓
Touch ID prompt appears
           ↓
✓ authenticated → script runs
✗ failed → nothing happens
```

**Use cases:**
- Protect deploy scripts from eager AI agents (Cursor, Copilot)
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

<details>
<summary>Build manually</summary>

```bash
make build

# Or directly
swiftc -O -o shelllock Sources/shelllock.swift
```

**SDK mismatch fix:**

```bash
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```
</details>

<br/>

## Usage

```bash
# Basic
shelllock ./deploy.sh

# Custom prompt
shelllock -m "Deploy to production?" ./deploy.sh

# Inline command
shelllock -c "npm run build && npm test"
```

### Self-protecting scripts

Add to top of any script:

```bash
#!/bin/bash
if [[ "${SHELLLOCK_VERIFIED:-}" != "1" ]]; then
    exec env SHELLLOCK_VERIFIED=1 shelllock -m "Run this script?" "$0" "$@"
fi
```

<br/>

## Tools Used

<img src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift"/>
<img src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS"/>
<img src="https://img.shields.io/badge/LocalAuthentication-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="LocalAuthentication"/>
<img src="https://img.shields.io/badge/Homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=black" alt="Homebrew"/>

<br/>

## Related

- [applock-macos](https://github.com/vdutts7/applock-macos) — Touch ID gate for `.app` bundles

<br/>

## Contact

<a href="https://vd7.io"><img src="https://res.cloudinary.com/ddyc1es5v/image/upload/v1773910810/readme-badges/readme-badge-vd7.png" alt="vd7.io" height="40" /></a> &nbsp; <a href="https://x.com/vdutts7"><img src="https://res.cloudinary.com/ddyc1es5v/image/upload/v1773910817/readme-badges/readme-badge-x.png" alt="/vdutts7" height="40" /></a>

<!-- MARKDOWN LINKS -->

[github]: https://img.shields.io/badge/Github-2496ED?style=for-the-badge&logo=github&logoColor=white&color=black
[github-url]: https://github.com/vdutts7/shelllock-macos
[homebrew]: https://img.shields.io/badge/Homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=black
[homebrew-url]: https://github.com/vdutts7/homebrew-tap
[email]: https://img.shields.io/badge/me@vd7.io-FFCA28?style=for-the-badge&logo=Gmail&logoColor=00bbff&color=black
[email-url]: mailto:me@vd7.io
[twitter]: https://img.shields.io/badge/Twitter-FFCA28?style=for-the-badge&logo=Twitter&logoColor=00bbff&color=black
[twitter-url]: https://twitter.com/vdutts7/
