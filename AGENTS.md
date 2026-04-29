# AI Agent Guide: Updating Operating Systems

This document provides instructions for AI agents to update the `build/operating-systems.json` file with new Operating System images discovered in the `build/ami.db` database.

## Overview

The AWS AMI project maintains a database of Amazon Machine Images (AMIs) in `build/ami.db` and a JSON configuration file `build/operating-systems.json` that defines filters for the website generation tool `build/web.pl`.

## Database Structure

The `build/ami.db` is a SQLite database created by `build/build.sh` with the following schema:

```sql
CREATE TABLE "images" (
    "imageId" TEXT NOT NULL DEFAULT "",
    "name" TEXT NOT NULL DEFAULT "",
    "architecture" TEXT NOT NULL DEFAULT "",
    "ownerId" TEXT NOT NULL DEFAULT "",
    "description" TEXT NOT NULL DEFAULT "",
    -- ... other fields
    PRIMARY KEY("imageId")
);
```

Key fields:
- `ownerId`: AWS account ID of the AMI publisher
- `name`: AMI name (used for pattern matching)
- `description`: Human-readable description

## Operating Systems JSON Structure

The `build/operating-systems.json` file has the following structure:

```json
[
    {
        "owner": "099720109477",
        "name": "ubuntu",
        "description": "Ubuntu",
        "versions": [
            {
                "filter": "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04",
                "name": "ubuntu-24-04",
                "description": "Ubuntu 24.04 (Noble Numbat)"
            }
        ]
    }
]
```

### Owner IDs Reference

| Owner ID | Operating System |
|----------|------------------|
| 013907871322 | SUSE |
| 099720109477 | Ubuntu / Ubuntu Pro |
| 125523088429 | Fedora / CentOS Stream |
| 136693071363 | Debian |
| 137112412989 | Amazon Linux |
| 309956199498 | Red Hat Enterprise Linux |
| 628277914472 | Apple macOS |
| 647457786197 | Arch Linux |
| 764336703387 | AlmaLinux |
| 782442783595 | FreeBSD |
| 792107900819 | Rocky Linux |
| 801119661308 | Microsoft Windows Server |

## Step-by-Step Update Process

### 1. Identify New OS Versions

Query the database to find new OS versions:

```bash
cd ./build/

# Example: Check for new Ubuntu versions
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '099720109477' AND (name LIKE 'ubuntu/images/hvm%' OR name LIKE 'ubuntu-minimal/images/hvm%') ORDER BY name"

# Example: Check for new RHEL versions
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '309956199498' AND name LIKE 'RHEL-9.%' ORDER BY name"

# Example: Check for new Fedora versions
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '125523088429' AND (name LIKE 'Fedora-Cloud-Base%' OR name LIKE 'fedora-coreos%') ORDER BY name"
```

### 2. Extract Pattern Filters

Analyze the AMI names to create appropriate filter patterns:

**Common Patterns:**

- **Ubuntu**: `ubuntu/images/hvm-ssd-gp3/ubuntu-{codename}-{version}`
  - Example: `ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04`
  
- **Ubuntu Minimal**: `ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-{codename}-{version}`
  
- **RHEL**: `RHEL-{version}` or `RHEL_HA-{version}`
  - Example: `RHEL-9.7`, `RHEL_HA-9.7`
  
- **Rocky Linux**: `Rocky-{major}-EC2-Base-{version}` or `Rocky-{major}-EC2-LVM-{version}`
  - Example: `Rocky-9-EC2-Base-9.7`
  
- **AlmaLinux**: `AlmaLinux OS {version}`
  - Example: `AlmaLinux OS 9.7`
  
- **Fedora**: `Fedora-Cloud-Base-AmazonEC2\.[a-z0-9_]*-{version}`
  - Example: `Fedora-Cloud-Base-AmazonEC2\.aarch64-45`
  
- **Fedora CoreOS**: `fedora-coreos-{version}`
  
- **SUSE**: `suse-sles-{version}-v[0-9]*-hvm`
  - Example: `suse-sles-16-0-chost-byos-v[0-9]*-hvm`
  
- **Windows**: `TPM-Windows_Server-{version}-English-{edition}-Base`
  - Example: `TPM-Windows_Server-2025-English-Full-Base`

### 3. Update the JSON File

Use the `edit` tool to add new versions to the appropriate OS section:

```json
{
    "filter": "ubuntu/images/hvm-ssd-gp3/ubuntu-questing-25.10",
    "name": "ubuntu-25-10",
    "description": "Ubuntu 25.10 (Questing)"
}
```

**Important Notes:**
- Add new versions at the END of the versions array (before the closing `]`)
- Maintain alphabetical or version number order when possible
- Use proper JSON formatting (commas between objects, no trailing comma)
- Follow existing naming conventions (e.g., `ubuntu-25-10`, not `ubuntu-25.10`)

### 4. Validate JSON

Always validate the JSON after making changes:

```bash
jq -e '.' operating-systems.json > /dev/null && echo "✓ JSON is valid"
```

### 5. Verify with Git Diff

Review your changes:

```bash
git diff operating-systems.json
```

## Common Update Patterns

### Adding a New Ubuntu Version

```json
{
    "filter": "ubuntu/images/hvm-ssd-gp3/ubuntu-{codename}-{version}",
    "name": "ubuntu-{major}-{minor}",
    "description": "Ubuntu {version} ({Codename})"
},
{
    "filter": "ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-{codename}-{version}",
    "name": "ubuntu-{major}-{minor}-minimal",
    "description": "Ubuntu {version} ({Codename}) Minimal"
}
```

### Adding a New RHEL Version

```json
{
    "filter": "RHEL-{version}",
    "name": "rhel-{major}-{minor}",
    "description": "RHEL {version}"
},
{
    "filter": "RHEL_HA-{version}",
    "name": "rhel-{major}-{minor}-ha",
    "description": "RHEL {version} with HA"
}
```

### Adding a New Rocky Linux Version

```json
{
    "filter": "Rocky-{major}-EC2-Base-{version}",
    "name": "rocky-linux-{major}-{minor}",
    "description": "Rocky {version}"
},
{
    "filter": "Rocky-{major}-EC2-LVM-{version}",
    "name": "rocky-linux-{major}-{minor}-lvm",
    "description": "Rocky {version} with LVM"
}
```

### Adding a New Fedora Version

```json
{
    "filter": "Fedora-Cloud-Base-AmazonEC2\\.[a-z0-9_]*-{version}",
    "name": "fedora-{version}",
    "description": "Fedora {version}"
},
{
    "filter": "fedora-coreos-{version}",
    "name": "coreos-{version}",
    "description": "Fedora CoreOS {version}"
}
```

## Testing

After updating `operating-systems.json`, you can test the changes by:

1. Running the build script:
   ```bash
   cd /Users/nils/Developer/aws-ami/build
   ./build.sh
   ```

2. Checking the website generation:
   ```bash
   perl web.pl
   ```

## Checklist

- [ ] Query database for new OS versions
- [ ] Identify correct filter patterns from AMI names
- [ ] Add entries to `operating-systems.json` in the correct section
- [ ] Follow existing naming conventions
- [ ] Validate JSON syntax
- [ ] Review changes with `git diff`
- [ ] Ensure no duplicate entries
- [ ] Test if possible

## Example Queries for Each OS

### Ubuntu
```bash
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '099720109477' AND name LIKE 'ubuntu/images/hvm-ssd-gp3/ubuntu-%' ORDER BY name DESC LIMIT 20"
```

### RHEL
```bash
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '309956199498' AND (name LIKE 'RHEL-9.%' OR name LIKE 'RHEL-10.%') ORDER BY name"
```

### Rocky Linux
```bash
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '792107900819' AND name LIKE 'Rocky-%' ORDER BY name DESC LIMIT 20"
```

### AlmaLinux
```bash
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '764336703387' AND name LIKE 'AlmaLinux OS %' ORDER BY name DESC LIMIT 20"
```

### Fedora
```bash
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '125523088429' AND (name LIKE 'Fedora-Cloud-Base%' OR name LIKE 'fedora-coreos-%') ORDER BY name DESC LIMIT 20"
```

### SUSE
```bash
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '013907871322' AND name LIKE 'suse-sles-%' ORDER BY name DESC LIMIT 20"
```

### Debian
```bash
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '136693071363' AND name LIKE 'debian-%' ORDER BY name DESC LIMIT 20"
```

### Windows Server
```bash
sqlite3 ami.db "SELECT DISTINCT name FROM images WHERE ownerId = '801119661308' AND name LIKE '%Windows_Server-%' ORDER BY name DESC LIMIT 20"
```

## Version Information

- Last Updated: 2026-04-29
- Database: `build/ami.db`
- Config File: `build/operating-systems.json`
- Build Script: `build/build.sh`
- Web Generator: `build/web.pl`

## Notes

- The filter patterns use regular expressions for flexibility
- Special regex characters need escaping (e.g., `\.` for literal dots)
- Version numbers in filters can use `[0-9]*` or specific patterns
- Always maintain backward compatibility with existing filters
- The website generation tool reads this JSON to fetch the latest AMIs matching the filters
