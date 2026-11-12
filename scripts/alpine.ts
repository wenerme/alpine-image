#!/usr/bin/env bun

import { readFile } from 'node:fs/promises';
import path from 'node:path';

const root = path.resolve(import.meta.dir, '..');
const versionFile = path.join(root, 'builds', 'VERSION');

function option(name: string): string | undefined {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

function normalizeVersion(value: string): string {
  const version = value.trim().replace(/^v/, '');
  if (!/^\d+\.\d+\.\d+$/.test(version)) {
    throw new Error(`invalid Alpine version: ${value}`);
  }
  return version;
}

function normalizeTag(value: string): string {
  const tag = value.trim();
  if (!/^[A-Za-z0-9][A-Za-z0-9._-]*$/.test(tag)) {
    throw new Error(`invalid release tag: ${value}`);
  }
  return tag;
}

async function currentVersion(): Promise<string> {
  return normalizeVersion(await readFile(versionFile, 'utf8'));
}

async function main(): Promise<void> {
  const command = process.argv[2] ?? 'help';

  if (command === 'version') {
    console.log(await currentVersion());
    return;
  }

  if (command === 'release-info') {
    const version = normalizeVersion(option('--version') || await currentVersion());
    const tag = normalizeTag(option('--tag') || `alpine-${version}`);
    const targets = [
      { name: 'x86_64-lts', arch: 'x86_64', flavor: 'lts' },
      { name: 'x86_64-virt', arch: 'x86_64', flavor: 'virt' },
      { name: 'aarch64-lts', arch: 'aarch64', flavor: 'lts' },
      { name: 'aarch64-virt', arch: 'aarch64', flavor: 'virt' },
    ];

    console.log(JSON.stringify({
      version,
      tag,
      title: `AlpineLinux ${version}`,
      targets,
      assetPattern: `alpine-*-*-${version}.img.gz`,
    }));
    return;
  }

  console.error('Usage: bun scripts/alpine.ts version|release-info [--version VERSION] [--tag TAG]');
  process.exitCode = 2;
}

try {
  await main();
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
}
