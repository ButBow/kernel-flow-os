"""
Kernel Launcher Service
=======================
Local bridge between Kernel Flow OS (web app) and local tools/Claude Code.
Runs on http://localhost:8421

Responsibilities:
- Launch local tools (bat files, Python GUIs)
- Check tool status (is it running?)
- Launch Claude Code in any directory
- Serve modules.json config to the web app
- Handle workspace activation (launch multiple tools at once)
- Auto git-pull the Kernel Flow OS repo on demand

Usage:
    python launcher_service.py

Requirements:
    pip install fastapi uvicorn psutil
"""

import json
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Optional

import psutil
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# ============================================================
# CONFIG
# ============================================================

SERVICE_PORT = 8421
REPO_PATH = Path(__file__).parent.parent  # C:\Users\flori\Desktop\Kernel_Kontrolle
MODULES_JSON = Path(__file__).parent / "modules.json"

# ============================================================
# APP
# ============================================================

app = FastAPI(
    title="Kernel Launcher Service",
    description="Local bridge for Kernel Flow OS — launches tools and Claude Code",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow the Lovable app (any origin, local only anyway)
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
# MODELS
# ============================================================

class LaunchRequest(BaseModel):
    tool_id: str

class ClaudeCodeRequest(BaseModel):
    path: str
    model: Optional[str] = None  # e.g. "opus" for --model opus

class WorkspaceActivateRequest(BaseModel):
    workspace_id: str

class GitPullRequest(BaseModel):
    pass

# ============================================================
# HELPERS
# ============================================================

def load_modules() -> dict:
    with open(MODULES_JSON, "r", encoding="utf-8") as f:
        return json.load(f)

def find_tool(tool_id: str) -> Optional[dict]:
    modules = load_modules()
    for tool in modules.get("tools", []):
        if tool["id"] == tool_id:
            return tool
    return None

def find_workspace(workspace_id: str) -> Optional[dict]:
    modules = load_modules()
    for ws in modules.get("workspaces", []):
        if ws["id"] == workspace_id:
            return ws
    return None

def is_port_open(port: int) -> bool:
    """Check if something is listening on a port."""
    for conn in psutil.net_connections():
        if conn.laddr.port == port and conn.status == "LISTEN":
            return True
    return False

def get_tool_status(tool: dict) -> str:
    """Returns 'running', 'stopped', or 'unknown'."""
    if tool.get("port"):
        return "running" if is_port_open(tool["port"]) else "stopped"
    # For GUI tools without ports, we can't easily check — return unknown
    return "unknown"

def launch_bat(bat_path: str) -> dict:
    """Launch a .bat file detached (non-blocking)."""
    bat = Path(bat_path)
    if not bat.exists():
        return {"success": False, "error": f"Launch script not found: {bat_path}"}
    try:
        subprocess.Popen(
            [str(bat)],
            cwd=str(bat.parent),
            creationflags=subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP,
            close_fds=True
        )
        return {"success": True, "launched": str(bat)}
    except Exception as e:
        return {"success": False, "error": str(e)}

# ============================================================
# ROUTES
# ============================================================

@app.get("/")
def root():
    return {
        "service": "Kernel Launcher Service",
        "version": "1.0.0",
        "port": SERVICE_PORT,
        "status": "running",
        "repo": str(REPO_PATH)
    }

@app.get("/health")
def health():
    return {"status": "ok", "timestamp": time.time()}

# ─── MODULES ────────────────────────────────────────────────

@app.get("/modules")
def get_modules():
    """Return full modules.json config — Kernel Flow OS reads this on load."""
    return load_modules()

@app.get("/modules/status")
def get_all_status():
    """Return running status for all tools."""
    modules = load_modules()
    statuses = {}
    for tool in modules.get("tools", []):
        statuses[tool["id"]] = {
            "name": tool["name"],
            "status": get_tool_status(tool),
            "webUrl": tool.get("webUrl")
        }
    return statuses

@app.get("/modules/{tool_id}/status")
def get_tool_status_route(tool_id: str):
    tool = find_tool(tool_id)
    if not tool:
        raise HTTPException(status_code=404, detail=f"Tool '{tool_id}' not found")
    return {"id": tool_id, "status": get_tool_status(tool)}

# ─── LAUNCH ─────────────────────────────────────────────────

@app.post("/launch/{tool_id}")
def launch_tool(tool_id: str):
    """Launch a local tool by ID."""
    tool = find_tool(tool_id)
    if not tool:
        raise HTTPException(status_code=404, detail=f"Tool '{tool_id}' not found")
    result = launch_bat(tool["launchScript"])
    return {"tool": tool_id, "name": tool["name"], **result}

@app.post("/workspace/activate")
def activate_workspace(req: WorkspaceActivateRequest):
    """Activate a workspace — launches all its tools."""
    ws = find_workspace(req.workspace_id)
    if not ws:
        raise HTTPException(status_code=404, detail=f"Workspace '{req.workspace_id}' not found")

    results = []
    for tool_id in ws.get("launchTools", []):
        tool = find_tool(tool_id)
        if tool:
            result = launch_bat(tool["launchScript"])
            results.append({"tool": tool_id, **result})

    return {
        "workspace": req.workspace_id,
        "name": ws["name"],
        "launched": results,
        "claudeCodePath": ws.get("claudeCodePath")
    }

# ─── CLAUDE CODE ─────────────────────────────────────────────

@app.post("/claude-code/launch")
def launch_claude_code(req: ClaudeCodeRequest):
    """
    Launch Claude Code in a specific directory.
    Opens a new Windows Terminal / cmd window with claude running.
    """
    target_path = Path(req.path)
    if not target_path.exists():
        raise HTTPException(status_code=400, detail=f"Path does not exist: {req.path}")

    cmd = "claude"
    if req.model:
        cmd += f" --model {req.model}"

    try:
        # Open Windows Terminal in the target directory with claude
        subprocess.Popen(
            ["wt", "-d", str(target_path), "cmd", "/k", cmd],
            creationflags=subprocess.DETACHED_PROCESS | subprocess.CREATE_NEW_PROCESS_GROUP
        )
        return {"success": True, "path": str(target_path), "command": cmd, "method": "wt"}
    except FileNotFoundError:
        # Windows Terminal not available, fall back to cmd
        try:
            subprocess.Popen(
                f'start cmd /k "cd /d {target_path} && {cmd}"',
                shell=True,
                creationflags=subprocess.DETACHED_PROCESS
            )
            return {"success": True, "path": str(target_path), "command": cmd, "method": "cmd"}
        except Exception as e:
            return {"success": False, "error": str(e)}

@app.get("/claude-code/projects")
def get_claude_projects():
    """Read Claude Code project list from ~/.claude/projects/"""
    claude_projects_dir = Path.home() / ".claude" / "projects"
    if not claude_projects_dir.exists():
        return {"projects": []}

    projects = []
    for project_dir in claude_projects_dir.iterdir():
        if project_dir.is_dir():
            # Convert directory name back to path (e.g., D--Tools -> D:\Tools)
            raw = project_dir.name
            path_guess = raw.replace("--", ":\\", 1).replace("-", "\\")
            projects.append({
                "id": raw,
                "name": project_dir.name,
                "path": path_guess,
                "sessions": len(list(project_dir.glob("*.json*")))
            })

    return {"projects": sorted(projects, key=lambda x: x["name"])}

@app.get("/claude-code/quick-paths")
def get_quick_paths():
    """Return quick-access Claude Code paths from modules.json."""
    modules = load_modules()
    return {"paths": modules.get("claudeCode", {}).get("quickPaths", [])}

# ─── FILES ──────────────────────────────────────────────────

@app.get("/files/browse")
def browse_directory(path: str = "C:\\Users\\flori"):
    """Browse directory contents for the Claude Code launcher."""
    target = Path(path)
    if not target.exists() or not target.is_dir():
        raise HTTPException(status_code=400, detail="Invalid directory")

    entries = []
    try:
        for entry in sorted(target.iterdir()):
            if entry.name.startswith("."):
                continue
            entries.append({
                "name": entry.name,
                "path": str(entry),
                "isDir": entry.is_dir(),
                "hasClaude": (entry / "CLAUDE.md").exists() or (entry / ".claude").exists()
            })
    except PermissionError:
        raise HTTPException(status_code=403, detail="Permission denied")

    return {
        "path": str(target),
        "parent": str(target.parent) if target.parent != target else None,
        "entries": entries
    }

# ─── GIT SYNC ────────────────────────────────────────────────

@app.post("/git/pull")
def git_pull():
    """Pull latest changes from GitHub (Lovable pushes here)."""
    try:
        result = subprocess.run(
            ["git", "pull"],
            cwd=str(REPO_PATH),
            capture_output=True,
            text=True,
            timeout=30
        )
        return {
            "success": result.returncode == 0,
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip(),
            "returncode": result.returncode
        }
    except subprocess.TimeoutExpired:
        return {"success": False, "error": "git pull timed out"}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/git/status")
def git_status():
    """Check current git status of the repo."""
    try:
        result = subprocess.run(
            ["git", "log", "--oneline", "-5"],
            cwd=str(REPO_PATH),
            capture_output=True,
            text=True,
            timeout=10
        )
        return {
            "success": True,
            "recent_commits": result.stdout.strip().split("\n"),
            "repo": str(REPO_PATH)
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

# ─── SYSTEM ──────────────────────────────────────────────────

@app.get("/system/info")
def system_info():
    """Basic system info for the dashboard."""
    return {
        "cpu_percent": psutil.cpu_percent(interval=0.1),
        "ram_percent": psutil.virtual_memory().percent,
        "ram_used_gb": round(psutil.virtual_memory().used / (1024**3), 1),
        "ram_total_gb": round(psutil.virtual_memory().total / (1024**3), 1),
    }

# ============================================================
# STARTUP
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Kernel Launcher Service")
    print(f"  Running on http://localhost:{SERVICE_PORT}")
    print(f"  Repo: {REPO_PATH}")
    print("=" * 60)
    uvicorn.run(app, host="127.0.0.1", port=SERVICE_PORT, log_level="warning")
