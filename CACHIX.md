# Binary Cache Setup (Cachix & FlakeHub)

This project uses both Cachix and FlakeHub to speed up builds by caching compiled Nix packages and Rust artifacts.

## Configuration

### Local Development

1. **Authentication**: Copy `.envrc.local.example` to `.envrc.local` and add your tokens:
   ```bash
   cp .envrc.local.example .envrc.local
   # Edit .envrc.local and replace <TOKEN> placeholders with your actual tokens
   ```

2. **Get your tokens**:
   - **Cachix**: Generate token at https://app.cachix.org/personal-auth-tokens
   - **FlakeHub**: Generate token at https://flakehub.com/settings/tokens

3. **Automatic loading**: Both tokens are automatically loaded by direnv when you enter the project directory.

4. **Current Status**: ✅ Both tokens are configured in `.envrc.local`

### GitHub Actions

The CI/CD workflows are configured to use both Cachix and FlakeHub. You need to add the following secrets to your GitHub repository:

#### Cachix Token:
1. Go to Settings → Secrets and variables → Actions
2. Add a new repository secret named `CACHIX_AUTH_TOKEN`
3. Paste your Cachix auth token as the value

#### FlakeHub Token:
1. Go to Settings → Secrets and variables → Actions
2. Add a new repository secret named `FLAKEHUB_PUSH_TOKEN`
3. Get your FlakeHub token from https://flakehub.com/settings/tokens
4. Paste the token as the value

### Cache Information

#### Cachix:
- **Cache name**: `mikkihugo`
- **Public key**: `mikkihugo.cachix.org-1:TJ+vwFP1XImrAATJbqWLaEvtzuWpui9hw5stDdeOTAE=`

#### FlakeHub:
- **Cache name**: `singularity-analysis`
- **Visibility**: Public
- **URL**: https://flakehub.com/f/Singularity-ng/singularity-analysis-engine

### Benefits

- ✅ **Dual cache layers** - Both Cachix and FlakeHub for maximum availability
- ✅ **Faster CI builds** - Cached dependencies across all workflows
- ✅ **Faster local builds** - Shared cache between developers
- ✅ **Reduced build times** - Nix packages cached and available instantly
- ✅ **Cached Rust artifacts** - Compilation results stored and reused
- ✅ **Public visibility** - FlakeHub cache is publicly accessible for faster pulls

### Pushing to Cache

With the auth token configured:
- **Local builds**: Automatically pushed when using `nix develop`
- **CI builds**: Automatically pushed during GitHub Actions workflows

### Using devenv (Alternative Setup)

If you prefer using devenv, the project includes a `devenv.nix` configuration:

```bash
# Install devenv
nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable

# Enter the development shell
devenv shell
```

The devenv configuration automatically handles Cachix push operations.

## Troubleshooting

If you encounter permission issues:
```bash
# Ensure your user is trusted
echo "trusted-users = $USER" | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon
```

## Security Notes

- Never commit `.envrc.local` or any file containing the auth token
- The auth token provides write access to the cache
- Use repository secrets for CI/CD environments