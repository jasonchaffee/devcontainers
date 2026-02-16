#!/usr/bin/env python3
import json
import sys
import os
import subprocess

# =============================================================================
# Configuration
# =============================================================================
CONTEXT_LIMIT = 200000

# Model emojis
MODEL_EMOJIS = {
    'opus': '🧠',
    'sonnet': '⚡',
    'haiku': '🚀',
}

# Context thresholds and colors
CONTEXT_COLORS = [
    (50, '🟢'),   # 0-50%: healthy
    (75, '🟡'),   # 50-75%: caution
    (90, '🟠'),   # 75-90%: warning
    (100, '🔴'),  # 90%+: critical
]

# =============================================================================
# Helper Functions
# =============================================================================
def get_model_emoji(model_name):
    """Get emoji for model based on name."""
    model_lower = model_name.lower()
    for key, emoji in MODEL_EMOJIS.items():
        if key in model_lower:
            return emoji
    return '🤖'  # Default

def get_context_color(percentage):
    """Get color emoji based on context percentage."""
    for threshold, emoji in CONTEXT_COLORS:
        if percentage <= threshold:
            return emoji
    return '🔴'

def get_git_info():
    """Get git branch and status indicators."""
    # Check if in a git repo
    if not os.path.exists('.git'):
        # Could be in a subdirectory, try git command
        try:
            result = subprocess.run(
                ['git', 'rev-parse', '--is-inside-work-tree'],
                capture_output=True, text=True, timeout=2
            )
            if result.returncode != 0:
                return None, None
        except:
            return None, None

    branch = None
    is_main = False

    # Get branch name
    try:
        # Try reading .git/HEAD first (faster)
        if os.path.exists('.git/HEAD'):
            with open('.git/HEAD', 'r') as f:
                ref = f.read().strip()
                if ref.startswith('ref: refs/heads/'):
                    branch = ref.replace('ref: refs/heads/', '')

        # Fallback to git command
        if not branch:
            result = subprocess.run(
                ['git', 'branch', '--show-current'],
                capture_output=True, text=True, timeout=2
            )
            if result.returncode == 0:
                branch = result.stdout.strip()
    except:
        pass

    if not branch:
        return None, None

    is_main = branch in ('main', 'master')

    # Get git status indicators
    status_indicators = ""
    try:
        result = subprocess.run(
            ['git', 'status', '--porcelain'],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode == 0 and result.stdout.strip():
            statuses = set()
            for line in result.stdout.strip().split('\n'):
                if len(line) >= 2:
                    index_status = line[0]
                    work_status = line[1]

                    # Staged changes (index)
                    if index_status == 'A':
                        statuses.add('added')
                    elif index_status == 'M':
                        statuses.add('modified')
                    elif index_status == 'D':
                        statuses.add('deleted')
                    elif index_status == 'R':
                        statuses.add('renamed')

                    # Unstaged changes (working tree)
                    if work_status == 'M':
                        statuses.add('modified')
                    elif work_status == 'D':
                        statuses.add('deleted')

                    # Untracked
                    if index_status == '?' and work_status == '?':
                        statuses.add('untracked')

                    # Unmerged
                    if index_status == 'U' or work_status == 'U':
                        statuses.add('unmerged')

            # Build status string (order matches zsh theme)
            if 'added' in statuses:
                status_indicators += '✚'
            if 'modified' in statuses:
                status_indicators += '✹'
            if 'deleted' in statuses:
                status_indicators += '✖'
            if 'renamed' in statuses:
                status_indicators += '➜'
            if 'unmerged' in statuses:
                status_indicators += '═'
            if 'untracked' in statuses:
                status_indicators += '✭'
    except:
        pass

    # Format branch with emoji
    branch_emoji = '🏠' if is_main else '🌿'
    branch_str = f"{branch_emoji} {branch}"
    if status_indicators:
        branch_str += f" {status_indicators}"

    return branch_str, is_main

def get_context_usage(transcript_path):
    """Parse transcript to get context usage."""
    context_used = 0

    try:
        with open(transcript_path, 'r') as f:
            lines = f.readlines()

        # Iterate from last line to first
        for line in reversed(lines):
            line = line.strip()
            if not line:
                continue

            try:
                obj = json.loads(line)
                if (obj.get('type') == 'assistant' and
                    'message' in obj and
                    'usage' in obj['message']):
                    usage = obj['message']['usage']
                    input_tokens = usage.get('input_tokens', 0)
                    cache_creation = usage.get('cache_creation_input_tokens', 0)
                    cache_read = usage.get('cache_read_input_tokens', 0)
                    output_tokens = usage.get('output_tokens', 0)

                    context_used = input_tokens + cache_creation + cache_read + output_tokens
                    break
            except json.JSONDecodeError:
                continue
    except:
        pass

    return context_used

# =============================================================================
# Main
# =============================================================================
def main():
    # Read JSON from stdin
    data = json.load(sys.stdin)

    # Extract values
    model_name = data['model']['display_name']
    current_dir = os.path.basename(data['workspace']['current_dir'])
    transcript_path = data['transcript_path']

    # Get model emoji
    model_emoji = get_model_emoji(model_name)

    # Get git info
    git_branch, _ = get_git_info()

    # Get context usage
    context_used = get_context_usage(transcript_path)
    context_percentage = (context_used / CONTEXT_LIMIT) * 100
    context_color = get_context_color(context_percentage)

    # Build status line
    parts = [
        f"{model_emoji} {model_name}",
        f"📁 {current_dir}",
    ]

    if git_branch:
        parts.append(git_branch)

    parts.append(f"{context_color} {context_percentage:.0f}% ({context_used:,}/{CONTEXT_LIMIT:,})")

    print(" | ".join(parts))

if __name__ == '__main__':
    main()
