# enx - Encryptix CLI

The official command-line tool for [Encryptix](https://encryptix.io) - SSH into your IoT devices and manage your fleet from the terminal.

## Install

### Homebrew (macOS Apple Silicon)

```bash
brew tap encryptixio/tap
brew install enx
```

### Shell script (macOS and Linux)

```bash
curl -sSfL https://raw.githubusercontent.com/encryptixio/homebrew-tap/main/install.sh | sh
```

### From source

Requires [Rust](https://rustup.rs/).

```bash
cargo install --git https://github.com/encryptixio/backend.git enx
```

## Quick start

### 1. Log in

```bash
enx login
```

This opens your browser to authenticate. Log in with your Encryptix account (Google, email/password, or SSO). The CLI picks up the token automatically when you're done.

```
$ enx login
Your authorization code: KQRG-VSFT

Opening browser to: https://auth.encryptix.io/activate?user_code=KQRG-VSFT
If the browser doesn't open, copy the URL above and paste it in your browser.

Waiting for authorization...... done!
Logged in as user@company.com (org: My Organization)

Generating SSH config...
SSH config generated. You can now use:
  enx ssh root@<device-name>
  ssh root@<device-name>.encryptix
```

Alternatively, provide a token directly:

```bash
enx login --token <your-jwt>
```

### 2. SSH into a device

Use `enx ssh` for a direct connection:

```bash
enx ssh root@my-device
```

Or use standard `ssh` (configured automatically on login):

```bash
ssh root@my-device.encryptix
```

Both methods support **device name**, **SSH alias**, or **device UUID**:

```bash
enx ssh root@my-device                                    # by name
enx ssh pi@my-alias                                       # by SSH alias
enx ssh root@25f731dc-f2a8-48d6-bdd1-b2955e410bfd        # by UUID

ssh root@my-device.encryptix                              # standard SSH by name
ssh pi@my-alias.encryptix                                 # standard SSH by alias
```

If no username is specified, `root` is used by default:

```bash
enx ssh my-device                                         # connects as root
```

The standard SSH method also works with `scp`, `rsync`, and any tool that uses SSH:

```bash
scp file.txt root@my-device.encryptix:/tmp/
rsync -avz ./data/ root@my-device.encryptix:/opt/data/
```

## Commands

| Command | Description |
|---------|-------------|
| `enx login` | Authenticate via browser (opens Auth0 login page) |
| `enx login --token <jwt>` | Authenticate with a JWT token directly |
| `enx ssh [user@]<device>` | SSH into a device by name, alias, or UUID |
| `enx ssh-config` | Regenerate SSH config for `*.encryptix` hosts |
| `enx version` | Print the installed version |
| `enx help` | Show usage information |

## How it works

`enx` provides two ways to connect to your devices:

**`enx ssh`** — creates a PTY session and bridges your terminal directly over an encrypted WebSocket connection through the Encryptix gateway. Simplest method, no SSH daemon required on the device.

**`ssh user@device.encryptix`** — uses a standard SSH client with an auto-configured `ProxyCommand`. The CLI tunnels the SSH protocol through the Encryptix gateway to the device's SSH daemon (port 22). Supports `scp`, `rsync`, port forwarding, and all standard SSH features.

Both methods authenticate via the Encryptix API using the token from `enx login`. All connections are encrypted via TLS. No inbound ports need to be opened on your devices.

## Configuration

`enx` stores its config in `~/.encryptix/config.json`. You can override settings with environment variables:

| Variable | Description |
|----------|-------------|
| `ENCRYPTIX_API_URL` | API endpoint (default: `https://api.encryptix.io`) |
| `ENCRYPTIX_API_TOKEN` | JWT token (overrides stored token) |

The SSH config is stored in `~/.ssh/encryptix_config` and included automatically in `~/.ssh/config`. Run `enx ssh-config` to regenerate it.

## Requirements

- macOS 12+ or Linux (glibc 2.31+)
- An [Encryptix](https://encryptix.io) account with at least one enrolled device

## Troubleshooting

**"Token expired" when running `enx ssh`**
Run `enx login` to re-authenticate.

**"device not found" error**
Check that the device name, alias, or UUID is correct. The device must be online and enrolled in your organization.

**"failed to enable raw terminal mode"**
`enx ssh` requires a real terminal (TTY). It won't work inside non-interactive shells or pipes. Use `ssh user@device.encryptix` instead.

**Standard SSH (`ssh user@device.encryptix`) not working**
Run `enx ssh-config` to regenerate the SSH config. Check that `~/.ssh/config` contains `Include ~/.ssh/encryptix_config` at the top.

## Security

- Tokens are stored in `~/.encryptix/config.json` with `0600` permissions (owner-only read/write)
- All API and WebSocket connections use TLS
- Authentication uses the OAuth 2.0 Device Authorization flow (no passwords stored locally)
- The CLI binary is built from source in GitHub Actions and published with SHA256 checksums

## License

MIT
